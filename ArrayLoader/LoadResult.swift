// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/// The `Value` type of `SignalProducer` values returned from `LoadStrategy` implementations.
///
/// A load result always updates the current elements – an empty array is, of course, permitted. Additionally, it may
/// override any of the page state on the `StrategyArrayLoader` – whether or not the there are further next or previous
/// pages, and the next and previous `Info` values.
///
/// Even when loading a next page, the previous page states can be overwritten – this is intended to allow an initial
/// next page to initialize a reference to the previous page for future requests.
public struct LoadResult<Element, Info>
{
    // MARK: - Initialization
    
    /**
     Initializes a load result.
     
     - parameter elements:            The elements that were loaded.
     - parameter nextPageHasMore:     A mutation value for whether or not the array loader has a next page.
                                      If this parameter is omitted, the default value is `.DoNotReplace`.
     - parameter previousPageHasMore: A mutation value for whether or not the array loader has a previous page.
                                      If this parameter is omitted, the default value is `.DoNotReplace`.
     - parameter nextPageInfo:        A mutation value for the array loader's next page info.
                                      If this parameter is omitted, the default value is `.DoNotReplace`.
     - parameter previousPageInfo:    A mutation value for the array loader's previous page info.
                                      If this parameter is omitted, the default value is `.DoNotReplace`.
     */
    public init(
        elements: [Element],
        nextPageHasMore: Mutation<Bool> = .DoNotReplace,
        previousPageHasMore: Mutation<Bool> = .DoNotReplace,
        nextPageInfo: Mutation<Info> = .DoNotReplace,
        previousPageInfo: Mutation<Info> = .DoNotReplace)
    {
        self.elements = elements
        self.nextPageHasMore = nextPageHasMore
        self.previousPageHasMore = previousPageHasMore
        self.nextPageInfo = nextPageInfo
        self.previousPageInfo = previousPageInfo
    }
    
    // MARK: - Elements
    
    /// The elements that were loaded.
    let elements: [Element]
    
    // MARK: - Page States
    
    /// A mutation value for whether or not the array loader has a next page.
    let nextPageHasMore: Mutation<Bool>
    
    /// A mutation value for whether or not the array loader has a previous page.
    let previousPageHasMore: Mutation<Bool>
    
    // MARK: - Infos
    
    /// A mutation value for the array loader's next page info.
    let nextPageInfo: Mutation<Info>
    
    /// A mutation value for the array loader's previous page info.
    let previousPageInfo: Mutation<Info>
}
