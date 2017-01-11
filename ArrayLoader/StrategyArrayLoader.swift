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
import enum Result.NoError

/// An array loader that uses strategy functions to retrieve and combine element arrays.
///
/// `StrategyArrayLoader` load strategies should derive everything necessary to load a page from a `LoadRequest` value,
/// which is associated with the next or previous page, and contains an array of the current elements. If additional
/// data is needed to load a page, use `InfoStrategyArrayLoader` instead.
public final class StrategyArrayLoader<Element, Error: Swift.Error>
{
    // MARK: - Strategy Types
    
    /// The function type used to load additional array pages.
    ///
    /// Currently, only a single `next` value is supported. Subsequent values will be discarded.
    public typealias LoadStrategy = (LoadRequest<Element>) -> SignalProducer<LoadResult<Element>, Error>
    
    // MARK: - Initialization
    
    /**
    Initializes a strategy array loader.

    - parameter load:            The load strategy to use.
    */
    public init(load: @escaping LoadStrategy)
    {
        self.backing = InfoStrategyArrayLoader(
            nextInfo: (),
            previousInfo: (),
            load: { request in
                load(request.loadRequest).map({ result in
                    InfoLoadResult(
                        elements: result.elements,
                        nextPageHasMore: result.nextPageHasMore,
                        previousPageHasMore: result.previousPageHasMore,
                        nextPageInfo: .doNotReplace,
                        previousPageInfo: .doNotReplace
                    )
                })
            }
        )
    }
    
    // MARK: - Backing
    
    /// The backing info strategy array loader.
    fileprivate let backing: InfoStrategyArrayLoader<Element, Void, Error>
}

extension StrategyArrayLoader: ArrayLoader
{
    // MARK: - State
    
    /// The current state of the array loader.
    public var state: Property<LoaderState<Element, Error>>
    {
        return backing.state
    }

    // MARK: - Page Events

    /// The events for the array loader.
    public var events: SignalProducer<LoaderEvent<Element, Error>, NoError>
    {
        return backing.events
    }
    
    // MARK: - Loading Pages
    
    /// Loads the next page of the array loader, if one is available. If the next page is already loading, or no next
    /// page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.loading` when this function is called, as long as the next page state is not `.completed`.
    public func loadNextPage()
    {
        backing.loadNextPage()
    }
    
    /// Loads the previous page of the array loader, if one is available. If the previous page is already loading, or no
    /// previous page is available, this function does nothing.
    ///
    /// Although load strategies can execute synchronously, the next page state of the array loader will always
    /// change to `.loading` when this function is called, as long as the next page state is not `.completed`.
    public func loadPreviousPage()
    {
        backing.loadPreviousPage()
    }
}
