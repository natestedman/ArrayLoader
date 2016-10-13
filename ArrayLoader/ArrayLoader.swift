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
    associatedtype Element
    
    /// The error type of the array loader.
    associatedtype Error: ErrorType
    
    // MARK: - State
    
    /// The current state of the array loader.
    var state: AnyProperty<LoaderState<Element, Error>> { get }

    // MARK: - Events

    /// A producer for the events of the array loader. When started, this producer will immediately yield a
    /// `.Current` event.
    var events: SignalProducer<LoaderEvent<Element, Error>, NoError> { get }
    
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
    // MARK: - Properties
    
    /// The elements currently loaded by the array loader.
    public var elements: [Element]
    {
        return state.value.elements
    }
    
    /// The next page state of the array loader.
    public var nextPageState: PageState<Error>
    {
        return state.value.nextPageState
    }
    
    /// The previous page state of the array loader.
    public var previousPageState: PageState<Error>
    {
        return state.value.previousPageState
    }
}

extension ArrayLoader
{
    // MARK: - Transformations

    /// Transforms the array loader's elements.
    ///
    /// - parameter transform: An element function.
    @warn_unused_result
    public func mapElements<Other>(transform: Element -> Other) -> AnyArrayLoader<Other, Error>
    {
        return AnyArrayLoader(
            arrayLoader: self,
            transformState: { $0.mapElements(transform) },
            transformEvents: { $0.mapElements(transform) }
        )
    }

    /// Transforms the array loader's errors.
    ///
    /// - parameter transform: An error transform function.
    @warn_unused_result
    public func mapErrors<Other: ErrorType>(transform: Error -> Other) -> AnyArrayLoader<Element, Other>
    {
        return AnyArrayLoader(
            arrayLoader: self,
            transformState: { $0.mapErrors(transform) },
            transformEvents: { $0.mapErrors(transform) }
        )
    }
}

extension ArrayLoader where Error == NoError
{
    // MARK: - Composition Support

    /**
    Promotes a non-erroring array loader to be compatible with error-yielding array loaders.

    - parameter error: The error type to promote to.
    */
    @warn_unused_result
    public func promoteErrors<Promoted: ErrorType>(error: Promoted.Type) -> AnyArrayLoader<Element, Promoted>
    {
        return mapErrors({ $0 as! Promoted })
    }
}
