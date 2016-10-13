// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/// Encapsulates the state of an `ArrayLoader` in a single value type.
public struct LoaderState<Element, Error: ErrorType>
{
    // MARK: - Elements
    /// The elements that have been loaded.
    public let elements: [Element]
    
    // MARK: - Page States
    /// The next page loading state.
    public let nextPageState: PageState<Error>
    
    /// The previous page loading state.
    public let previousPageState: PageState<Error>
}


extension LoaderState
{
    // MARK: - Transformations

    /**
     Transforms the loader state's element type.

     - parameter transform: A transformation function.

     - returns: A loader state with the transformed elements, and the same page states.
     */
    public func mapElements<Other>(transform: Element -> Other) -> LoaderState<Other, Error>
    {
        return LoaderState<Other, Error>(
            elements: elements.map(transform),
            nextPageState: nextPageState,
            previousPageState: previousPageState
        )
    }

    /**
    Transforms the loader state's error type.

    - parameter transform: An error transformation function.

    - returns: A loader state with the same elements, and transformed page states.
    */
    public func mapErrors<Other: ErrorType>(transform: Error -> Other) -> LoaderState<Element, Other>
    {
        return LoaderState<Element, Other>(
            elements: elements,
            nextPageState: nextPageState.mapError(transform),
            previousPageState: previousPageState.mapError(transform)
        )
    }
}

// MARK: - Equatability

/**
Returns `true` if the two `LoaderState` values are equal.

`LoaderState` cannot confirm to `Equatable`, but this operator is provided as a utility.

- parameter lhs: The first loader state.
- parameter rhs: The second loader state.
*/
@warn_unused_result
public func ==<Element: Equatable, Error: ErrorType>(lhs: LoaderState<Element, Error>, rhs: LoaderState<Element, Error>) -> Bool
{
    return lhs.elements == rhs.elements
        && lhs.nextPageState == rhs.nextPageState
        && lhs.previousPageState == rhs.previousPageState
}
