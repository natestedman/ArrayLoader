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

/// Uses strategy functions provided at initialization to load array data.
///
/// Currently, only a single `next` value is supported for load strategies. Subsequent values will be ignored.
public final class StrategyArrayLoader<Element, Info, Error: ErrorType>
{
    // MARK: - Strategy Types
    
    /// The function type used to load additional array pages.
    public typealias LoadStrategy = LoadRequest<Element, Info> -> SignalProducer<LoadResult<Element, Info>, Error>
    
    /// The type used to combine array pages with current information.
    public typealias CombineStrategy = ([Element], [Element]) -> [Element]
    
    // MARK: - State
    
    /// Backing property for `state`.
    let _state = MutableProperty(LoaderState<Element, Error>(
        elements: [],
        nextPageState: .HasMore,
        previousPageState: .HasMore
    ))
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>
    
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
    public init(
        nextInfo: Info,
        previousInfo: Info,
        load: LoadStrategy,
        combineNext: CombineStrategy = (+),
        combinePrevious: CombineStrategy = (+))
    {
        // set infos
        self.nextInfo = nextInfo
        self.previousInfo = previousInfo
        
        // set strategies
        loadStrategy = load
        nextCombineStrategy = combineNext
        previousCombineStrategy = combinePrevious
        
        // set up public properties
        state = AnyProperty(_state)
    }
    
    // MARK: - Info
    
    /// The current info value for the next page.
    var nextInfo: Info
    
    /// The current info value for the previous page.
    var previousInfo: Info
    
    // MARK: - Strategies
    
    /// The load strategy.
    let loadStrategy: LoadStrategy
    
    // The combine strategy used for appending next pages to the array.
    let nextCombineStrategy: CombineStrategy
    
    /// The combine strategy used for prepending previous pages to the array.
    let previousCombineStrategy: CombineStrategy
}

extension StrategyArrayLoader where Info: EmptyInfo
{
    // MARK: - Empty Info
    
    /**
    Initializes a strategy array loader with default info values for both pages.
    
    - parameter load:            The load strategy to use.
    - parameter combineNext:     The combine strategy to use for next pages. The first parameter sent to this function
                                 is the current content, and the second parameter is the newly loaded content. If this
                                 parameter is omitted, `+` will be used.
    - parameter combinePrevious: The combine strategy to use for previous pages. The first parameter sent to this
                                 function is the new loadeded content, and the second parameter is the current content.
                                 If this parameter is omitted, `+` will be used.
    */
    public convenience init(
        load: LoadStrategy,
        combineNext: CombineStrategy = (+),
        combinePrevious: CombineStrategy = (+))
    {
        self.init(
            nextInfo: Info(),
            previousInfo: Info(),
            load: load,
            combineNext: combineNext,
            combinePrevious: combinePrevious
        )
    }
}

// MARK: - ArrayLoader
extension StrategyArrayLoader: ArrayLoader
{
    // MARK: - Loading Pages
    
    /// Loads the next page of the array loader, if one is available. If the next page is already loading, or no next
    /// page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.Loading` when this function is called, as long as the next page state is not `.Complete`.
    public func loadNextPage()
    {
        if nextPageState.value.hasMore
        {
            let elements = _state.value.elements
            
            // set the next page state to loading
            _state.value = LoaderState(
                elements: elements,
                nextPageState: .Loading,
                previousPageState: _state.value.previousPageState
            )
            
            loadStrategy(LoadRequest.Next(current: elements, info: nextInfo))
                .take(1)
                .on(next: { [weak self] result in
                    if let strongSelf = self
                    {
                        let state = strongSelf._state.value
                        
                        strongSelf.nextInfo = result.nextPageInfo.value ?? strongSelf.nextInfo
                        strongSelf.previousInfo = result.previousPageInfo.value ?? strongSelf.nextInfo
                        
                        strongSelf._state.value = LoaderState<Element, Error>(
                            elements: strongSelf.nextCombineStrategy(state.elements, result.elements),
                            
                            nextPageState: result.nextPageHasMore.value.map({ hasMore in
                                hasMore ? .HasMore : .Complete
                            }) ?? .HasMore,
                            
                            previousPageState: result.previousPageHasMore.value.map({ hasMore in
                                hasMore ? .HasMore : .Complete
                            }) ?? state.previousPageState
                        )
                    }
                }, failed: { [weak self] error in
                    if let strongSelf = self
                    {
                        let state = strongSelf._state.value
                        
                        strongSelf._state.value = LoaderState(
                            elements: state.elements,
                            nextPageState: .Failed(error),
                            previousPageState: state.previousPageState
                        )
                    }
                })
                .start()
        }
    }
    
    /// Loads the previous page of the array loader, if one is available. If the previous page is already loading, or no
    /// previous page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.Loading` when this function is called, as long as the next page state is not `.Complete`.
    public func loadPreviousPage()
    {
        if previousPageState.value.hasMore
        {
            let elements = _state.value.elements
            
            // set the next page state to loading
            _state.value = LoaderState(
                elements: elements,
                nextPageState: _state.value.previousPageState,
                previousPageState: .Loading
            )
            
            loadStrategy(LoadRequest.Previous(current: elements, info: previousInfo))
                .take(1)
                .on(next: { [weak self] result in
                    if let strongSelf = self
                    {
                        let state = strongSelf._state.value
                        
                        strongSelf.nextInfo = result.nextPageInfo.value ?? strongSelf.nextInfo
                        strongSelf.previousInfo = result.previousPageInfo.value ?? strongSelf.nextInfo
                        
                        strongSelf._state.value = LoaderState(
                            elements: strongSelf.nextCombineStrategy(result.elements, state.elements),
                            
                            nextPageState: result.nextPageHasMore.value.map({ hasMore in
                                hasMore ? .HasMore : .Complete
                            }) ?? state.nextPageState,
                            
                            previousPageState: result.previousPageHasMore.value.map({ hasMore in
                                hasMore ? .HasMore : .Complete
                            }) ?? .HasMore
                        )
                    }
                }, failed: { [weak self] error in
                    if let strongSelf = self
                    {
                        let state = strongSelf._state.value
                        
                        strongSelf._state.value = LoaderState(
                            elements: state.elements,
                            nextPageState: state.nextPageState,
                            previousPageState: .Failed(error)
                        )
                    }
                })
                .start()
        }
    }
}

