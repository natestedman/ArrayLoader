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
import enum Result.NoError

/// Wraps any array loader of the given element and error types in a single type.
///
/// `loadNextPage()` and `loadPreviousPage()` can be called on either the wrapped array loader or on this class. The
/// results of both will be the same - the implementations for this class merely call the wrapped versions.
public struct AnyArrayLoader<Element, Error: ErrorType>
{
    // MARK: - Loader State
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>

    // MARK: - Events

    /// The wrapped array loader's events.
    public let events: SignalProducer<LoaderEvent<Element, Error>, NoError>
    
    // MARK: - Load Functions
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    private let _loadNextPage: () -> ()
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    private let _loadPreviousPage: () -> ()
    
    // MARK: - Initialization
    private init(
        state: AnyProperty<LoaderState<Element, Error>>,
        events: SignalProducer<LoaderEvent<Element, Error>, NoError>,
        loadNextPage: () -> (),
        loadPreviousPage: () -> ())
    {
        self.state = state
        self.events = events
        _loadNextPage = loadNextPage
        _loadPreviousPage = loadPreviousPage
    }
}

extension AnyArrayLoader
{
    // MARK: - Initialization

    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` and a transform function to map the array loader's elements.

     - parameter arrayLoader:      The array loader to wrap.
     - parameter transformElement: The element transform function.
     */
    public init<Wrapped: ArrayLoader where Wrapped.Error == Error>
        (arrayLoader: Wrapped, transformElement: Wrapped.Element -> Element)
    {
        self.init(
            state: arrayLoader.state.map({ state in
                state.mapElements(transformElement)
            }),
            events: arrayLoader.events.map({ $0.mapElements(transformElement) }),
            loadNextPage: arrayLoader.loadNextPage,
            loadPreviousPage: arrayLoader.loadPreviousPage
        )
    }
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` and a transform function to map the array loader's errors.
     
     - parameter arrayLoader:     The array loader to wrap.
     - parameter transformErrors: The error transform function.
     */
    public init<Wrapped: ArrayLoader where Wrapped.Element == Element>
        (arrayLoader: Wrapped, transformErrors: Wrapped.Error -> Error)
    {
        self.init(
            state: arrayLoader.state.map({ state in
                return LoaderState(
                    elements: state.elements,
                    nextPageState: state.nextPageState.mapError(transformErrors),
                    previousPageState: state.previousPageState.mapError(transformErrors)
                )
            }),
            events: arrayLoader.events.map({ $0.mapError(transformErrors) }),
            loadNextPage: arrayLoader.loadNextPage,
            loadPreviousPage: arrayLoader.loadPreviousPage
        )
    }
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` that matches element and error types.
     
     - parameter arrayLoader: The array loader to wrap.
     */
    public init<Wrapped: ArrayLoader where Wrapped.Element == Element, Wrapped.Error == Error>(_ arrayLoader: Wrapped)
    {
        self.init(
            state: arrayLoader.state,
            events: arrayLoader.events,
            loadNextPage: arrayLoader.loadNextPage,
            loadPreviousPage: arrayLoader.loadPreviousPage
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
