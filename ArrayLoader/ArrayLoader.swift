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

/// The base protocol for array loader types.
///
/// An array loader incrementally builds an array of `Element` values by loading `previous` and `next` pages. These
/// pages can be infinite – bounded only by memory limits, or can terminate.
///
/// The current state of the array loader is tracked through the current `state` value, of type `LoaderState`. This
/// includes the current array and the states for the current `previous` and `next` pages: whether they have more
/// values, have completed, are currently loading more values, or failed to load more values. The failure case includes
/// an associated error of type `Error`. The possible page states are documented in more detail in the `PageState` type.
public protocol ArrayLoader
{
    // MARK: - Types
    
    /// The element type of the array loader.
    typealias Element
    
    /// The error type of the array loader.
    typealias Error: ErrorType
    
    // MARK: - State
    
    /// The current state of the array loader.
    var state: AnyProperty<LoaderState<Element, Error>> { get }
    
    // MARK: - Loading Elements
    
    /// Instructs the array loader to load its next page. If the next page is already loading, this function should do
    /// nothing.
    func loadNextPage()
    
    /// Instructs the array loader to load the previous page. If the previous page is already loading, this function
    /// should do nothing.
    func loadPreviousPage()
}

// MARK: - State Extensions
extension ArrayLoader
{
    // MARK: - Utilities
    
    /**
    Returns a property created by transforming the array loader's current state.
    
    - parameter transform: A transform function.
    */
    private func transformedStateProperty<T>(transform: LoaderState<Element, Error> -> T) -> DerivedProperty<T>
    {
        return DerivedProperty(wrapped: AnyProperty(
            initialValue: transform(state.value),
            producer: state.producer.skip(1).map(transform)
        ))
    }
    
    // MARK: - Properties
    
    /// The elements currently loaded by the array loader.
    public var elements: DerivedProperty<[Element]>
    {
        return transformedStateProperty({ state in state.elements })
    }
    
    /// The next page state of the array loader.
    public var nextPageState: DerivedProperty<PageState<Error>>
    {
        return transformedStateProperty({ state in state.nextPageState })
    }
    
    /// The previous page state of the array loader.
    public var previousPageState: DerivedProperty<PageState<Error>>
    {
        return transformedStateProperty({ state in state.previousPageState })
    }
}
