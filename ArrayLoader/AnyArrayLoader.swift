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

/// Wraps any array loader of the given element and error types in a single type.
///
/// `loadNextPage()` and `loadPreviousPage()` can be called on either the wrapped array loader or on this class. The
/// results of both will be the same - the implementations for this class merely call the wrapped versions.
public struct AnyArrayLoader<Element, Error: Swift.Error>
{
    // MARK: - Loader State
    
    /// The current state of the array loader.
    public let state: Property<LoaderState<Element, Error>>

    // MARK: - Events

    /// The wrapped array loader's events.
    public let events: SignalProducer<LoaderEvent<Element, Error>, NoError>
    
    // MARK: - Load Functions
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    fileprivate let _loadNextPage: () -> ()
    
    /// Avoids generic restrictions by not directly referencing the wrapped array loader.
    fileprivate let _loadPreviousPage: () -> ()
    
    // MARK: - Initialization
    fileprivate init(
        state: Property<LoaderState<Element, Error>>,
        events: SignalProducer<LoaderEvent<Element, Error>, NoError>,
        loadNextPage: @escaping () -> (),
        loadPreviousPage: @escaping () -> ())
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

    /// An internal initializer, used for `ArrayLoader` transformation extension functions.
    internal init<Wrapped: ArrayLoader>
        (arrayLoader: Wrapped,
         transformState: @escaping (LoaderState<Wrapped.Element, Wrapped.Error>) -> LoaderState<Element, Error>,
         transformEvents: @escaping (LoaderEvent<Wrapped.Element, Wrapped.Error>) -> LoaderEvent<Element, Error>)
    {
        self.init(
            state: arrayLoader.state.map(transformState),
            events: arrayLoader.events.map(transformEvents),
            loadNextPage: arrayLoader.loadNextPage,
            loadPreviousPage: arrayLoader.loadPreviousPage
        )
    }
    
    /**
     Initializes an `AnyArrayLoader` with an `ArrayLoader` that matches element and error types.
     
     - parameter arrayLoader: The array loader to wrap.
     */
    public init<Wrapped: ArrayLoader>(_ arrayLoader: Wrapped) where Wrapped.Element == Element, Wrapped.Error == Error
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
