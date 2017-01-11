// ArrayLoader
// Written in 2016 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

public enum LoaderEvent<Element, Error: Swift.Error>
{
    // MARK: - Cases

    /// An array loader's `events` producer will send this event when started, with the loader's current state.
    case current(state: LoaderState<Element, Error>)

    /// The array loader began to load its next page.
    case nextPageLoading(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// The array loader began to load its previous page.
    case previousPageLoading(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// This event will be send when the array loader successfully loads the next page.
    case nextPageLoaded(
        state: LoaderState<Element, Error>,
        previousState: LoaderState<Element, Error>,
        newElements: [Element]
    )

    /// This event will be send when the array loader successfully loads the previous page.
    case previousPageLoaded(
        state: LoaderState<Element, Error>,
        previousState: LoaderState<Element, Error>,
        newElements: [Element]
    )

    /// The array loader failed to load its next page.
    case nextPageFailed(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// The array loader failed to load its previous page.
    case previousPageFailed(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)
}

extension LoaderEvent
{
    // MARK: - Conditions

    /// `true` if the event is `.Current`.
    public var isCurrent: Bool
    {
        switch self
        {
        case .current:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.nextPageLoading`.
    public var isNextPageLoading: Bool
    {
        switch self
        {
        case .nextPageLoading:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.previousPageLoading`.
    public var isPreviousPageLoading: Bool
    {
        switch self
        {
        case .previousPageLoading:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.nextPageLoaded`.
    public var isNextPageLoaded: Bool
    {
        switch self
        {
        case .nextPageLoaded:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.previousPageLoaded`.
    public var isPreviousPageLoaded: Bool
    {
        switch self
        {
        case .previousPageLoaded:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.nextPageFailed`.
    public var isNextPageFailed: Bool
    {
        switch self
        {
        case .nextPageFailed:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.previousPageFailed`.
    public var isPreviousPageFailed: Bool
    {
        switch self
        {
        case .previousPageFailed:
            return true
        default:
            return false
        }
    }
}

extension LoaderEvent
{
    // MARK: - Contents

    /// The state of the array loader at the time of the event.
    public var state: LoaderState<Element, Error>
    {
        switch self
        {
        case let .current(state):
            return state
        case let .nextPageLoading(state, _):
            return state
        case let .previousPageLoading(state, _):
            return state
        case let .nextPageLoaded(state, _, _):
            return state
        case let .previousPageLoaded(state, _, _):
            return state
        case let .nextPageFailed(state, _):
            return state
        case let .previousPageFailed(state, _):
            return state
        }
    }

    /// The previous state of the array loader at the time of the event. `Current` events do not have a previous state.
    public var previousState: LoaderState<Element, Error>?
    {
        switch self
        {
        case .current:
            return nil
        case let .nextPageLoading(_, previousState):
            return previousState
        case let .previousPageLoading(_, previousState):
            return previousState
        case let .nextPageLoaded(_, previousState, _):
            return previousState
        case let .previousPageLoaded(_, previousState, _):
            return previousState
        case let .nextPageFailed(_, previousState):
            return previousState
        case let .previousPageFailed(_, previousState):
            return previousState
        }
    }

    /// The new elements that were added in this event.
    public var newElements: [Element]?
    {
        switch self
        {
        case let .nextPageLoaded(_, _, newElements):
            return newElements
        case let .previousPageLoaded(_, _, newElements):
            return newElements
        default:
            return nil
        }
    }
}

extension LoaderEvent
{
    // MARK: - Transformations

    /**
     Transforms the loader event's element type.

     - parameter transform: An element transformation function.
     */
    public func mapElements<Other>(_ transform: (Element) -> Other) -> LoaderEvent<Other, Error>
    {
        switch self
        {
        case let .current(state):
            return .current(state: state.mapElements(transform))

        case let .nextPageLoading(state, previousState):
            return .nextPageLoading(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .previousPageLoading(state, previousState):
            return .previousPageLoading(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .nextPageLoaded(state, previousState, newElements):
            return .nextPageLoaded(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform),
                newElements: newElements.map(transform)
            )

        case let .previousPageLoaded(state, previousState, newElements):
            return .previousPageLoaded(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform),
                newElements: newElements.map(transform)
            )

        case let .nextPageFailed(state, previousState):
            return .nextPageFailed(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .previousPageFailed(state, previousState):
            return .previousPageFailed(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )
        }
    }

    /**
     Transforms the loader event's error type.

     - parameter transform: An error transformation function.
     */
    public func mapErrors<Other: Swift.Error>(_ transform: (Error) -> Other) -> LoaderEvent<Element, Other>
    {
        switch self
        {
        case let .current(state):
            return .current(state: state.mapErrors(transform))

        case let .nextPageLoading(state, previousState):
            return .nextPageLoading(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform)
            )

        case let .previousPageLoading(state, previousState):
            return .previousPageLoading(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform)
            )

        case let .nextPageLoaded(state, previousState, newElements):
            return .nextPageLoaded(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform),
                newElements: newElements
            )

        case let .previousPageLoaded(state, previousState, newElements):
            return .previousPageLoaded(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform),
                newElements: newElements
            )

        case let .nextPageFailed(state, previousState):
            return .nextPageFailed(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform)
            )

        case let .previousPageFailed(state, previousState):
            return .previousPageFailed(
                state: state.mapErrors(transform),
                previousState: previousState.mapErrors(transform)
            )
        }
    }
}
