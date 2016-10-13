// ArrayLoader
// Written in 2016 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

public enum LoaderEvent<Element, Error: ErrorType>
{
    // MARK: - Cases

    /// An array loader's `events` producer will send this event when started, with the loader's current state.
    case Current(state: LoaderState<Element, Error>)

    /// The array loader began to load its next page.
    case NextPageLoading(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// The array loader began to load its previous page.
    case PreviousPageLoading(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// This event will be send when the array loader successfully loads the next page.
    case NextPageLoaded(
        state: LoaderState<Element, Error>,
        previousState: LoaderState<Element, Error>,
        newElements: [Element]
    )

    /// This event will be send when the array loader successfully loads the previous page.
    case PreviousPageLoaded(
        state: LoaderState<Element, Error>,
        previousState: LoaderState<Element, Error>,
        newElements: [Element]
    )

    /// The array loader failed to load its next page.
    case NextPageFailed(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)

    /// The array loader failed to load its previous page.
    case PreviousPageFailed(state: LoaderState<Element, Error>, previousState: LoaderState<Element, Error>)
}

extension LoaderEvent
{
    // MARK: - Conditions

    /// `true` if the event is `.Current`.
    public var isCurrent: Bool
    {
        switch self
        {
        case .Current:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.NextPageLoading`.
    public var isNextPageLoading: Bool
    {
        switch self
        {
        case .NextPageLoading:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.PreviousPageLoading`.
    public var isPreviousPageLoading: Bool
    {
        switch self
        {
        case .PreviousPageLoading:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.NextPageLoaded`.
    public var isNextPageLoaded: Bool
    {
        switch self
        {
        case .NextPageLoaded:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.PreviousPageLoaded`.
    public var isPreviousPageLoaded: Bool
    {
        switch self
        {
        case .PreviousPageLoaded:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.NextPageFailed`.
    public var isNextPageFailed: Bool
    {
        switch self
        {
        case .NextPageFailed:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.PreviousPageFailed`.
    public var isPreviousPageFailed: Bool
    {
        switch self
        {
        case .PreviousPageFailed:
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
        case let .Current(state):
            return state
        case let .NextPageLoading(state, _):
            return state
        case let .PreviousPageLoading(state, _):
            return state
        case let .NextPageLoaded(state, _, _):
            return state
        case let .PreviousPageLoaded(state, _, _):
            return state
        case let .NextPageFailed(state, _):
            return state
        case let .PreviousPageFailed(state, _):
            return state
        }
    }

    /// The previous state of the array loader at the time of the event. `Current` events do not have a previous state.
    public var previousState: LoaderState<Element, Error>?
    {
        switch self
        {
        case .Current:
            return nil
        case let .NextPageLoading(_, previousState):
            return previousState
        case let .PreviousPageLoading(_, previousState):
            return previousState
        case let .NextPageLoaded(_, previousState, _):
            return previousState
        case let .PreviousPageLoaded(_, previousState, _):
            return previousState
        case let .NextPageFailed(_, previousState):
            return previousState
        case let .PreviousPageFailed(_, previousState):
            return previousState
        }
    }

    /// The new elements that were added in this event.
    public var newElements: [Element]?
    {
        switch self
        {
        case let .NextPageLoaded(_, _, newElements):
            return newElements
        case let .PreviousPageLoaded(_, _, newElements):
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
    public func mapElements<Other>(transform: Element -> Other) -> LoaderEvent<Other, Error>
    {
        switch self
        {
        case let .Current(state):
            return .Current(state: state.mapElements(transform))

        case let .NextPageLoading(state, previousState):
            return .NextPageLoading(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .PreviousPageLoading(state, previousState):
            return .PreviousPageLoading(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .NextPageLoaded(state, previousState, newElements):
            return .NextPageLoaded(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform),
                newElements: newElements.map(transform)
            )

        case let .PreviousPageLoaded(state, previousState, newElements):
            return .PreviousPageLoaded(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform),
                newElements: newElements.map(transform)
            )

        case let .NextPageFailed(state, previousState):
            return .NextPageFailed(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )

        case let .PreviousPageFailed(state, previousState):
            return .PreviousPageFailed(
                state: state.mapElements(transform),
                previousState: previousState.mapElements(transform)
            )
        }
    }

    /**
     Transforms the loader event's error type.

     - parameter transform: An error transformation function.
     */
    public func mapError<Other: ErrorType>(transform: Error -> Other) -> LoaderEvent<Element, Other>
    {
        switch self
        {
        case let .Current(state):
            return .Current(state: state.mapError(transform))

        case let .NextPageLoading(state, previousState):
            return .NextPageLoading(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform)
            )

        case let .PreviousPageLoading(state, previousState):
            return .PreviousPageLoading(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform)
            )

        case let .NextPageLoaded(state, previousState, newElements):
            return .NextPageLoaded(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform),
                newElements: newElements
            )

        case let .PreviousPageLoaded(state, previousState, newElements):
            return .PreviousPageLoaded(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform),
                newElements: newElements
            )

        case let .NextPageFailed(state, previousState):
            return .NextPageFailed(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform)
            )

        case let .PreviousPageFailed(state, previousState):
            return .PreviousPageFailed(
                state: state.mapError(transform),
                previousState: previousState.mapError(transform)
            )
        }
    }
}
