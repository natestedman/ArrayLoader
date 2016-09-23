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

/// Wraps a static array in an array loader.
public struct StaticArrayLoader<Element>
{
    // MARK: - Initialization
    
    /**
    Initializes a static array loader.
    
    - parameter elements: The array of elements to use.
    */
    public init(elements: [Element])
    {
        state = AnyProperty(
            initialValue: LoaderState(elements: elements, nextPageState: .Completed, previousPageState: .Completed),
            producer: SignalProducer.empty
        )
    }
    
    // MARK: - State
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>
}

extension StaticArrayLoader
{
    // MARK: - Empty
    
    /// Returns an empty array loader, with both next and previous pages completed.
    public static var empty: StaticArrayLoader<Element>
    {
        return StaticArrayLoader(elements: [])
    }
}

// MARK: - ArrayLoader
extension StaticArrayLoader: ArrayLoader
{
    // MARK: - Typealiases
    public typealias Error = NoError
    
    // MARK: - Loading Elements
    
    /// Static array loaders only have one page, so this function does nothing.
    public func loadNextPage() {}
    
    /// Static array loaders only have one page, so this function does nothing.
    public func loadPreviousPage() {}
}
