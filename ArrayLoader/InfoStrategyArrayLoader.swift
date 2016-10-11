// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import ReactiveCocoa
import Result

/// An array loader that uses strategy functions to retrieve and combine element arrays, and provides an `Info`
/// parameter where arbitrary non-element data can be stored for the previous and next page. This data will be passed
/// to load strategies as part of an `InfoLoadRequest` value.
public final class InfoStrategyArrayLoader<Element, Info, Error: ErrorType>
{
    // MARK: - Strategy Types
    
    /// The function type used to load additional array pages.
    ///
    /// Currently, only a single `next` value is supported. Subsequent values will be discarded.
    public typealias LoadStrategy = InfoLoadRequest<Element, Info> -> SignalProducer<InfoLoadResult<Element, Info>, Error>
    
    // MARK: - Initialization
    
    /**
    Initializes a strategy array loader.
    
    - parameter nextInfo:        The initial next page info value.
    - parameter previousInfo:    The initial previous page info value.
    - parameter load:            The load strategy to use.
    - parameter combineNext:     The combine strategy to use for next pages. The first parameter sent to this function
                                 is the current content, and the second parameter is the newly loaded content. If this
                                 parameter is omitted, `+` will be used.
    - parameter combinePrevious: The combine strategy to use for previous pages. The first parameter sent to this
                                 function is the new loadeded content, and the second parameter is the current content.
                                 If this parameter is omitted, `+` will be used.
    */
    public init(nextInfo: Info, previousInfo: Info, load: LoadStrategy)
    {
        loadStrategy = load

        infoState = MutableProperty(InfoLoaderState(
            loaderState: LoaderState(
                elements: [],
                nextPageState: .HasMore,
                previousPageState: .HasMore
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
    public let state: AnyProperty<LoaderState<Element, Error>>
    
    // MARK: - Strategies
    
    /// The load strategy.
    let loadStrategy: LoadStrategy

    // MARK: - Pipes

    /// A backing pipe for `events`.
    private let eventsPipe = Signal<LoaderEvent<Element, Error>, NoError>.pipe()

    // MARK: - Page Disposables

    /// A disposable for the operation loading the next page.
    private let nextPageDisposable = SerialDisposable()

    /// A disposable for the operation loading the previous page.
    private let previousPageDisposable = SerialDisposable()
}

// MARK: - ArrayLoader
extension InfoStrategyArrayLoader: ArrayLoader
{
    // MARK: - Page Events

    /// The array loader's events.
    public var events: SignalProducer<LoaderEvent<Element, Error>, NoError>
    {
        return state.producer.take(1).map(LoaderEvent.Current).concat(SignalProducer(signal: eventsPipe.0))
    }

    // MARK: - Loading Pages
    
    /// Loads the next page of the array loader, if one is available. If the next page is already loading, or no next
    /// page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.Loading` when this function is called, as long as the next page state is not `.Completed`.
    public func loadNextPage()
    {
        guard state.value.nextPageState.isHasMore || state.value.nextPageState.error != nil else { return }

        // set the next page state to loading
        let current = infoState.modify({ current in
            InfoLoaderState(
                loaderState: LoaderState(
                    elements: current.loaderState.elements,
                    nextPageState: .Loading,
                    previousPageState: current.loaderState.previousPageState
                ),
                nextInfo: current.nextInfo,
                previousInfo: current.previousInfo
            )
        })

        eventsPipe.1.sendNext(.NextPageLoading(state: infoState.value.loaderState, previousState: current.loaderState))

        nextPageDisposable.innerDisposable =
            loadStrategy(.Next(current: current.loaderState.elements, info: current.nextInfo))
                .take(1)
                .startWithResult({ [weak self] result in
                    self?.nextPageCompletion(result: result)
                })
    }
    
    /// Loads the previous page of the array loader, if one is available. If the previous page is already loading, or no
    /// previous page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.Loading` when this function is called, as long as the next page state is not `.Completed`.
    public func loadPreviousPage()
    {
        guard state.value.previousPageState.isHasMore || state.value.previousPageState.error != nil else { return }
        
        // set the previous page state to loading
        let current = infoState.modify({ current in
            InfoLoaderState(
                loaderState: LoaderState(
                    elements: current.loaderState.elements,
                    nextPageState: current.loaderState.previousPageState,
                    previousPageState: .Loading
                ),
                nextInfo: current.nextInfo,
                previousInfo: current.previousInfo
            )
        })

        eventsPipe.1.sendNext(.PreviousPageLoading(
            state: infoState.value.loaderState,
            previousState: current.loaderState
        ))

        previousPageDisposable.innerDisposable =
            loadStrategy(.Previous(current: current.loaderState.elements, info: current.previousInfo))
                .take(1)
                .startWithResult({ [weak self] result in
                    self?.previousPageCompletion(result: result)
                })
    }
}

extension InfoStrategyArrayLoader
{
    // MARK: - Load Request Completion
    private typealias PageResult = Result<InfoLoadResult<Element, Info>, Error>
    private typealias PageStateForSuccess = (current: PageState<Error>, mutation: Mutation<Bool>) -> PageState<Error>
    private typealias PageStateForFailure = (current: PageState<Error>, error: Error) -> PageState<Error>

    static func currentIfNoMutation(current current: PageState<Error>, mutation: Mutation<Bool>) -> PageState<Error>
    {
        return mutation.value.map({ hasMore in hasMore ? .HasMore : .Completed }) ?? current
    }

    static func hasMoreIfNoMutation(current current: PageState<Error>, mutation: Mutation<Bool>) -> PageState<Error>
    {
        return mutation.value.map({ hasMore in hasMore ? .HasMore : .Completed }) ?? .HasMore
    }

    private func nextPageCompletion(result result: PageResult)
    {
        pageCompletion(
            result: result,
            combine: { current, new in current + new } ,
            pageEventForLoaded: LoaderEvent<Element, Error>.NextPageLoaded,
            pageEventForFailed: LoaderEvent.NextPageFailed,
            nextPageStateForSuccess: InfoStrategyArrayLoader.hasMoreIfNoMutation,
            previousPageStateForSuccess: InfoStrategyArrayLoader.currentIfNoMutation,
            nextPageStateForFailure: { _, error in .Failed(error) },
            previousPageStateForFailure: { current, _ in current }
        )
    }

    private func previousPageCompletion(result result: PageResult)
    {
        pageCompletion(
            result: result,
            combine: { current, new in new + current },
            pageEventForLoaded: LoaderEvent<Element, Error>.PreviousPageLoaded,
            pageEventForFailed: LoaderEvent.PreviousPageFailed,
            nextPageStateForSuccess: InfoStrategyArrayLoader.currentIfNoMutation,
            previousPageStateForSuccess: InfoStrategyArrayLoader.hasMoreIfNoMutation,
            nextPageStateForFailure: { current, _ in current },
            previousPageStateForFailure: { _, error in .Failed(error) }
        )
    }

    private func pageCompletion(result result: PageResult,
                                combine: (current: [Element], new: [Element]) -> [Element],
                                pageEventForLoaded: (LoaderState<Element, Error>, LoaderState<Element, Error>, [Element]) -> LoaderEvent<Element, Error>,
                                pageEventForFailed: (LoaderState<Element, Error>, LoaderState<Element, Error>) -> LoaderEvent<Element, Error>,
                                nextPageStateForSuccess: PageStateForSuccess,
                                previousPageStateForSuccess: PageStateForSuccess,
                                nextPageStateForFailure: PageStateForFailure,
                                previousPageStateForFailure: PageStateForFailure)
    {
        switch result
        {
        case let .Success(loadResult):
            infoState.modify({ current in
                let newState = InfoLoaderState(
                    loaderState: LoaderState(
                        elements: combine(current: current.loaderState.elements, new: loadResult.elements),
                        nextPageState: nextPageStateForSuccess(
                            current: current.loaderState.nextPageState,
                            mutation: loadResult.nextPageHasMore
                        ),
                        previousPageState: previousPageStateForSuccess(
                            current: current.loaderState.previousPageState,
                            mutation: loadResult.previousPageHasMore
                        )
                    ),
                    nextInfo: loadResult.nextPageInfo.value ?? current.nextInfo,
                    previousInfo: loadResult.previousPageInfo.value ?? current.previousInfo
                )

                eventsPipe.1.sendNext(pageEventForLoaded(newState.loaderState, current.loaderState, loadResult.elements))

                return newState
            })

        case let .Failure(error):
            infoState.modify({ current in
                let newState = InfoLoaderState(
                    loaderState: LoaderState(
                        elements: current.loaderState.elements,
                        nextPageState: nextPageStateForFailure(
                            current: current.loaderState.nextPageState,
                            error: error
                        ),
                        previousPageState: previousPageStateForFailure(
                            current: current.loaderState.previousPageState,
                            error: error
                        )
                    ),
                    nextInfo: current.nextInfo,
                    previousInfo: current.previousInfo
                )

                eventsPipe.1.sendNext(pageEventForFailed(newState.loaderState, current.loaderState))

                return newState
            })
        }
    }
}

struct InfoLoaderState<Element, Info, Error: ErrorType>
{
    let loaderState: LoaderState<Element, Error>
    let nextInfo: Info
    let previousInfo: Info
}
