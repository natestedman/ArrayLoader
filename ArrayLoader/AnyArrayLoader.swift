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

/// Wraps any array loader of the given element and error types in a single type.
///
/// `loadNextPage()` and `loadPreviousPage()` can be called on either the wrapped array loader or on this class. The
/// results of both will be the same - the implementations for this class merely call the wrapped versions.
public struct AnyArrayLoader<Element, Error: ErrorType>
{
    // MARK: - Loader State
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>
    
    // MARK: - Load Functions
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    private let _loadNextPage: () -> ()
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    private let _loadPreviousPage: () -> ()
    
    // MARK: - Initialization
    private init(
        state: AnyProperty<LoaderState<Element, Error>>,
        loadNextPage: () -> (),
        loadPreviousPage: () -> ())
    {
        self.state = state
        _loadNextPage = loadNextPage
        _loadPreviousPage = loadPreviousPage
    }
}

extension AnyArrayLoader
{
    // MARK: - Initialization
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` and a transform function to map the array loader's state.
     
     - parameter arrayLoader: The array loader to wrap.
     - parameter transform:   The state transform function.
     */
    public init<Wrapped: ArrayLoader>
        (arrayLoader: Wrapped, transform: LoaderState<Wrapped.Element, Wrapped.Error> -> LoaderState<Element, Error>)
    {
        self.init(
            state: AnyProperty<LoaderState<Element, Error>>(
                initialValue: transform(arrayLoader.state.value),
                producer: arrayLoader.state.producer.skip(1).map(transform)
            ),
            loadNextPage: Wrapped.loadNextPage(arrayLoader),
            loadPreviousPage: Wrapped.loadPreviousPage(arrayLoader)
        )
    }
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` that matches error types, and a transform function to map the
     array loader's elements.
     
     - parameter arrayLoader: The array loader to wrap.
     - parameter transform:   The element transform function.
     */
    public init<Wrapped: ArrayLoader where Wrapped.Error == Error>
        (arrayLoader: Wrapped, transform: Wrapped.Element -> Element)
    {
        self.init(
            arrayLoader: arrayLoader,
            transform: { state in
                LoaderState(
                    elements: state.elements.map(transform),
                    nextPageState: state.nextPageState,
                    previousPageState: state.previousPageState
                )
            }
        )
    }
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` that matches element and error types.
     
     - parameter arrayLoader: The array loader to wrap.
     */
    public init<Wrapped: ArrayLoader where Wrapped.Element == Element, Wrapped.Error == Error>
        (arrayLoader: Wrapped)
    {
        self.init(
            arrayLoader: arrayLoader,
            transform: { state -> LoaderState<Element, Error> in state }
        )
    }
}

// MARK: - ArrayLoader
extension AnyArrayLoader: ArrayLoader
{
    // MARK: - Loading Elements
    
    /// Instructs the wrapped array loader to load its next page.
    public func loadNextPage()
    {
        _loadNextPage()
    }
    
    /// Instructs the wrapped array loader to load its previous page.
    public func loadPreviousPage()
    {
        _loadPreviousPage()
    }
}
