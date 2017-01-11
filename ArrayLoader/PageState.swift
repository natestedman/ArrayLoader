// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import Foundation

/// Enumerates possible states for an array loader's next or previous pages.
///
/// `PageState` implements `Equatable`, but converts all error values to `NSError` in the `Failed` case. Therefore, for
/// equality to work correctly, it's important to implement `_code` and `_domain` in any `ErrorType` implementations
/// that will be used.
public enum PageState<Error: Swift.Error>
{
    /// The array loader at least one additional page to load.
    case hasMore
    
    /// The array loader is complete, and does not have an additional page to load.
    case completed
    
    /// The array loader is loading the page.
    case loading
    
    /// The page failed to load.
    case failed(Error)
}

extension PageState
{
    // MARK: - Properties
    
    /// `true` if the page state is `.hasMore`.
    public var isHasMore: Bool
    {
        switch self
        {
        case .hasMore:
            return true
        default:
            return false
        }
    }
    
    /// `true` if the page state is `.completed`.
    public var isCompleted: Bool
    {
        switch self
        {
        case .completed:
            return true
        default:
            return false
        }
    }
    
    /// `true` if the page state is `.loading`.
    public var isLoading: Bool
    {
        switch self
        {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    /// If the page state is `Failed`, the associated error. Otherwise, `nil`.
    public var error: Error?
    {
        switch self
        {
        case .failed(let error):
            return error
        default:
            return nil
        }
    }
}

extension PageState
{
    // MARK: - Error Transformations

    /**
    Transforms the page state's error type.

    - parameter transform: An error transformation function.

    - returns: If the page state is `.failed`, a `.failed` state with a transformed error. Otherwise, the same state,
               with a new associated error type.
    */
    public func mapError<Other: Swift.Error>(_ transform: (Error) -> Other) -> PageState<Other>
    {
        switch self
        {
        case .hasMore:
            return .hasMore
        case .completed:
            return .completed
        case .loading:
            return .loading
        case .failed(let error):
            return .failed(transform(error))
        }
    }
}

// MARK: - Equatable
extension PageState: Equatable {}

/**
 Returns `true` if the two `PageState` values are equal.
 
 `PageState` implements `Equatable`, but converts all error values to `NSError` in the `Failed` case. Therefore, for
 equality to work correctly, it's important to implement `_code` and `_domain` in any `ErrorType` implementations
 that will be used.
 
 - parameter lhs: The first loader state.
 - parameter rhs: The second loader state.
 */

public func ==<Error>(lhs: PageState<Error>, rhs: PageState<Error>) -> Bool
{
    switch (lhs, rhs)
    {
    case (.hasMore, .hasMore):
        return true
        
    case (.completed, .completed):
        return true
        
    case (.loading, .loading):
        return true
        
    case (.failed(let lhsError), .failed(let rhsError)):
        return lhsError as NSError == rhsError as NSError
        
    default:
        return false
    }
}

extension PageState: CustomDebugStringConvertible
{
    // MARK: - CustomDebugStringConvertible
    
    /// Returns the debug description for the page state.
    public var debugDescription: String
    {
        switch self
        {
        case .completed:
            return "Completed"
            
        case .hasMore:
            return "Has More"
            
        case .loading:
            return "Loading"
            
        case .failed(let error):
            return "Error: \(error)"
        }
    }
}
