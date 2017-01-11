// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import ReactiveSwift
import Result

/// An array loader that uses strategy functions to retrieve and combine element arrays, and provides an `Info`
/// parameter where arbitrary non-element data can be stored for the previous and next page. This data will be passed
/// to load strategies as part of an `InfoLoadRequest` value.
public final class InfoStrategyArrayLoader<Element, Info, Error: Swift.Error>
{
    // MARK: - Strategy Types
    
    /// The function type used to load additional array pages.
    ///
    /// Currently, only a single `next` value is supported. Subsequent values will be discarded.
    public typealias LoadStrategy = (InfoLoadRequest<Element, Info>) -> SignalProducer<InfoLoadResult<Element, Info>, Error>
    
    // MARK: - Initialization
    
    /**
    Initializes a strategy array loader.
    
    - parameter nextInfo:        The initial next page info value.
    - parameter previousInfo:    The initial previous page info value.
    - parameter load:            The load strategy to use.
    */
    public init(nextInfo: Info, previousInfo: Info, load: @escaping LoadStrategy)
    {
        loadStrategy = load

        infoState = MutableProperty(InfoLoaderState(
            loaderState: LoaderState(
                elements: [],
                nextPageState: .hasMore,
                previousPageState: .hasMore
            ),
            nextInfo: nextInfo,
            previousInfo: previousInfo
        ))

        state = infoState.map({ $0.loaderState })
    }

    deinit
    {
        nextPageDisposable.dispose()
        previousPageDisposable.dispose()
    }

    // MARK: - State
    
    /// A backing property for `state`, which also holds the array loader's info values.
    let infoState: MutableProperty<InfoLoaderState<Element, Info, Error>>
    
    /// The current state of the array loader.
    public let state: Property<LoaderState<Element, Error>>
    
    // MARK: - Strategies
    
    /// The load strategy.
    let loadStrategy: LoadStrategy

    // MARK: - Pipes

    /// A backing pipe for `events`.
    fileprivate let eventsPipe = Signal<LoaderEvent<Element, Error>, NoError>.pipe()

    // MARK: - Page Disposables

    /// A disposable for the operation loading the next page.
    fileprivate let nextPageDisposable = SerialDisposable()

    /// A disposable for the operation loading the previous page.
    fileprivate let previousPageDisposable = SerialDisposable()
}

// MARK: - ArrayLoader
extension InfoStrategyArrayLoader: ArrayLoader
{
    // MARK: - Page Events

    /// The array loader's events.
    public var events: SignalProducer<LoaderEvent<Element, Error>, NoError>
    {
        return state.producer.take(first: 1).map(LoaderEvent.current).concat(SignalProducer(eventsPipe.0))
    }

    // MARK: - Loading Pages
    
    /// Loads the next page of the array loader, if one is available. If the next page is already loading, or no next
    /// page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.loading` when this function is called, as long as the next page state is not `.completed`.
    public func loadNextPage()
    {
        guard state.value.nextPageState.isHasMore || state.value.nextPageState.error != nil else { return }

        // set the next page state to loading
        let current = infoState.modifyOld({ current in
            InfoLoaderState(
                loaderState: LoaderState(
                    elements: current.loaderState.elements,
                    nextPageState: .loading,
                    previousPageState: current.loaderState.previousPageState
                ),
                nextInfo: current.nextInfo,
                previousInfo: current.previousInfo
            )
        })

        eventsPipe.1.send(value: .nextPageLoading(state: infoState.value.loaderState, previousState: current.loaderState))

        nextPageDisposable.inner =
            loadStrategy(.next(current: current.loaderState.elements, info: current.nextInfo))
                .take(first: 1)
                .startWithResult({ [weak self] result in
                    self?.nextPageCompletion(result: result)
                })
    }
    
    /// Loads the previous page of the array loader, if one is available. If the previous page is already loading, or no
    /// previous page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.loading` when this function is called, as long as the next page state is not `.completed`.
    public func loadPreviousPage()
    {
        guard state.value.previousPageState.isHasMore || state.value.previousPageState.error != nil else { return }
        
        // set the previous page state to loading
        let previous = infoState.modifyOld({ current in
            InfoLoaderState(
                loaderState: LoaderState(
                    elements: current.loaderState.elements,
                    nextPageState: current.loaderState.previousPageState,
                    previousPageState: .loading
                ),
                nextInfo: current.nextInfo,
                previousInfo: current.previousInfo
            )
        })

        eventsPipe.1.send(value: .previousPageLoading(
            state: infoState.value.loaderState,
            previousState: previous.loaderState
        ))

        previousPageDisposable.inner =
            loadStrategy(.previous(current: previous.loaderState.elements, info: previous.previousInfo))
                .take(first: 1)
                .startWithResult({ [weak self] result in
                    self?.previousPageCompletion(result: result)
                })
    }
}

extension InfoStrategyArrayLoader
{
    // MARK: - Function Types
    fileprivate typealias PageStateForSuccess = (PageState<Error>, Mutation<Bool>) -> PageState<Error>
    fileprivate typealias PageStateForFailure = (PageState<Error>, Error) -> PageState<Error>

    /// A function type to transform an `InfoLoaderState` value.
    fileprivate typealias InfoLoaderStateTransform =
        (InfoLoaderState<Element, Info, Error>) -> InfoLoaderState<Element, Info, Error>

    /// A function type for creating a loader event from a current loader state, a previous loader state, and an array
    /// of newly-loaded elements.
    fileprivate typealias LoaderEventForStatesAndElements =
        (LoaderState<Element, Error>, LoaderState<Element, Error>, [Element]) -> LoaderEvent<Element, Error>

    /// A function type for creating a loader event from a current loader state and a previous loader state.
    fileprivate typealias LoaderEventForStates =
        (LoaderState<Element, Error>, LoaderState<Element, Error>) -> LoaderEvent<Element, Error>

    static func currentIfNoMutation(current: PageState<Error>, mutation: Mutation<Bool>) -> PageState<Error>
    {
        return mutation.value.map({ hasMore in hasMore ? .hasMore : .completed }) ?? current
    }

    static func hasMoreIfNoMutation(current: PageState<Error>, mutation: Mutation<Bool>) -> PageState<Error>
    {
        return mutation.value.map({ hasMore in hasMore ? .hasMore : .completed }) ?? .hasMore
    }

    // MARK: - Load Request Completion
    fileprivate typealias PageResult = Result<InfoLoadResult<Element, Info>, Error>

    /// Completes loading of the next page.
    ///
    /// - parameter result: The result from loading the next page.
    fileprivate func nextPageCompletion(result: PageResult)
    {
        pageCompletion(
            result: result,
            combine: { current, new in current + new } ,
            loaderEventForLoaded: LoaderEvent<Element, Error>.nextPageLoaded,
            loaderEventForFailed: LoaderEvent.nextPageFailed,
            nextPageStateForSuccess: InfoStrategyArrayLoader.hasMoreIfNoMutation,
            previousPageStateForSuccess: InfoStrategyArrayLoader.currentIfNoMutation,
            nextPageStateForFailure: { _, error in .failed(error) },
            previousPageStateForFailure: { current, _ in current }
        )
    }


    /// Completes loading of the previous page.
    ///
    /// - parameter result: The result from loading the previous page.
    fileprivate func previousPageCompletion(result: PageResult)
    {
        pageCompletion(
            result: result,
            combine: { current, new in new + current },
            loaderEventForLoaded: LoaderEvent<Element, Error>.previousPageLoaded,
            loaderEventForFailed: LoaderEvent.previousPageFailed,
            nextPageStateForSuccess: InfoStrategyArrayLoader.currentIfNoMutation,
            previousPageStateForSuccess: InfoStrategyArrayLoader.hasMoreIfNoMutation,
            nextPageStateForFailure: { current, _ in current },
            previousPageStateForFailure: { _, error in .failed(error) }
        )
    }

    /// Modifies the info loader state for a page completion event.
    ///
    /// - parameter transform: The info loader state transform.
    /// - parameter pageEvent: A function to create a page event, given the current and previous loader states.
    fileprivate func modifyStateForPageCompletion(transform: @escaping InfoLoaderStateTransform,
                                                  pageEvent: LoaderEventForStates)
    {
        var newState: InfoLoaderState<Element, Info, Error>?

        let previousState = infoState.modifyOld({ current in
            newState = transform(current)
            return newState!
        })

        eventsPipe.1.send(value: pageEvent(newState!.loaderState, previousState.loaderState))
    }

    /// Completes the loading of a page.
    ///
    /// - parameter result:                      The result of loading the page.
    /// - parameter combine:                     A function to combine the current and newly loaded elements.
    /// - parameter loaderEventForLoaded:          A function to create a page event for a successfully loaded page.
    /// - parameter loaderEventForFailed:          A function to create a page event for a failed page load.
    /// - parameter nextPageStateForSuccess:     A function to determine the next page state for a successfully loaded
    ///                                          page.
    /// - parameter previousPageStateForSuccess: A function to determine the previous page state for a successfully
    ///                                          loaded page.
    /// - parameter nextPageStateForFailure:     A function to determine the next page state for a failed page load.
    /// - parameter previousPageStateForFailure: A function to determine the previous page state for a failed page load.
    fileprivate func pageCompletion(result: PageResult,
                                    combine: @escaping ([Element], [Element]) -> [Element],
                                    loaderEventForLoaded: @escaping LoaderEventForStatesAndElements,
                                    loaderEventForFailed: @escaping LoaderEventForStates,
                                    nextPageStateForSuccess: @escaping PageStateForSuccess,
                                    previousPageStateForSuccess: @escaping PageStateForSuccess,
                                    nextPageStateForFailure: @escaping PageStateForFailure,
                                    previousPageStateForFailure: @escaping PageStateForFailure)
    {
        switch result
        {
        case let .success(loadResult):
            modifyStateForPageCompletion(
                transform: { current in
                    return InfoLoaderState(
                        loaderState: LoaderState(
                            elements: combine(current.loaderState.elements, loadResult.elements),
                            nextPageState: nextPageStateForSuccess(
                                current.loaderState.nextPageState,
                                loadResult.nextPageHasMore
                            ),
                            previousPageState: previousPageStateForSuccess(
                                current.loaderState.previousPageState,
                                loadResult.previousPageHasMore
                            )
                        ),
                        nextInfo: loadResult.nextPageInfo.value ?? current.nextInfo,
                        previousInfo: loadResult.previousPageInfo.value ?? current.previousInfo
                    )
                },
                pageEvent: { current, previous in loaderEventForLoaded(current, previous, loadResult.elements) }
            )

        case let .failure(error):
            modifyStateForPageCompletion(
                transform: { current in
                    InfoLoaderState(
                        loaderState: LoaderState(
                            elements: current.loaderState.elements,
                            nextPageState: nextPageStateForFailure(current.loaderState.nextPageState, error),
                            previousPageState: previousPageStateForFailure(current.loaderState.previousPageState, error)
                        ),
                        nextInfo: current.nextInfo,
                        previousInfo: current.previousInfo
                    )
                },
                pageEvent: loaderEventForFailed
            )
        }
    }
}

struct InfoLoaderState<Element, Info, Error: Swift.Error>
{
    let loaderState: LoaderState<Element, Error>
    let nextInfo: Info
    let previousInfo: Info
}
