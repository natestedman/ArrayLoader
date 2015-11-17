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
public enum PageState<Error: ErrorType>
{
    /// The array loader at least one additional page to load.
    case HasMore
    
    /// The array loader is complete, and does not have an additional page to load.
    case Completed
    
    /// The array loader is loading the page.
    case Loading
    
    /// The page failed to load.
    case Failed(Error)
}

extension PageState
{
    // MARK: - Properties
    
    /// `true` if the page state is `.HasMore`.
    public var isHasMore: Bool
    {
        switch self
        {
        case .HasMore:
            return true
        default:
            return false
        }
    }
    
    /// `true` if the page state is `.Completed`.
    public var isCompleted: Bool
    {
        switch self
        {
        case .Completed:
            return true
        default:
            return false
        }
    }
    
    /// `true` if the page state is `.Loading`.
    public var isLoading: Bool
    {
        switch self
        {
        case .Loading:
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
        case .Failed(let error):
            return error
        default:
            return nil
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
@warn_unused_result
public func ==<Error>(lhs: PageState<Error>, rhs: PageState<Error>) -> Bool
{
    switch (lhs, rhs)
    {
    case (.HasMore, .HasMore):
        return true
        
    case (.Completed, .Completed):
        return true
        
    case (.Loading, .Loading):
        return true
        
    case (.Failed(let lhsError), .Failed(let rhsError)):
        let lhsNSError = lhsError as NSError
        let rhsNSError = rhsError as NSError
        
        return lhsNSError == rhsNSError
        
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
        case .Completed:
            return "Completed"
            
        case .HasMore:
            return "Has More"
            
        case .Loading:
            return "Loading"
            
        case .Failed(let error):
            return "Error: \(error)"
        }
    }
}
