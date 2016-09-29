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

    /// This event will be send when the array loader successfully loads the next page.
    case Next(state: LoaderState<Element, Error>, newElements: [Element])

    /// This event will be send when the array loader successfully loads the previous page.
    case Previous(state: LoaderState<Element, Error>, newElements: [Element])
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

    /// `true` if the event is `.Next`.
    public var isNext: Bool
    {
        switch self
        {
        case .Next:
            return true
        default:
            return false
        }
    }

    /// `true` if the event is `.Previous`.
    public var isPrevious: Bool
    {
        switch self
        {
        case .Previous:
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
        case let .Next(state, _):
            return state
        case let .Previous(state, _):
            return state
        }
    }

    /// The new elements that were added in this event.
    public var newElements: [Element]?
    {
        switch self
        {
        case .Current:
            return nil
        case let .Next(_, newElements):
            return newElements
        case let .Previous(_, newElements):
            return newElements
        }
    }
}

extension LoaderEvent
{
    // MARK: - Error Transformations

    /**
     Transforms the page event's error type.

     - parameter transform: An error transformation function.
     */
    public func mapError<Other: ErrorType>(transform: Error -> Other) -> LoaderEvent<Element, Other>
    {
        switch self
        {
        case let .Current(state):
            return .Current(state: state.mapError(transform))
        case let .Next(state, newElements):
            return .Next(state: state.mapError(transform), newElements: newElements)
        case let .Previous(state, newElements):
            return .Previous(state: state.mapError(transform), newElements: newElements)
        }
    }
}
