// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/// A base protocol for load request types.
///
/// See `LoadRequest` and `InfoLoadRequest` for implementations.
public protocol LoadRequestType
{
    // MARK: - Types
    
    /// The element type of the array loader.
    associatedtype Element
    
    // MARK: - Properties
    
    /// Returns `true` if the load request is for the next page.
    var isNext: Bool { get }
    
    /// The current contents of the array loader.
    var current: [Element] { get }
}

extension LoadRequestType
{
    /// Returns `true` if the load request is for the previous page.
    public var isPrevious: Bool
    {
        return !isNext
    }
}

/// Passed to `StrategyArrayLoader`'s `LoadStrategy` to provide context for the page being loaded.
public enum LoadRequest<Element>: LoadRequestType
{
    // MARK: - Cases
    
    /**
     A load request for the next page of the array.
     
     - parameter current: The current contents of the array.
     */
    case Next(current: [Element])
    
    /**
     A load request for the previous page of the array.
     
     - parameter current: The current contents of the array.
     */
    case Previous(current: [Element])
    
    // MARK: - Properties
    
    /// Returns `true` if the load request is `.Next`.
    public var isNext: Bool
    {
        switch self
        {
        case .Next:
            return true
        case .Previous:
            return false
        }
    }
    
    /// The current contents of the array loader.
    public var current: [Element]
    {
        switch self
        {
        case .Next(let elements):
            return elements
        case .Previous(let elements):
            return elements
        }
    }
}

/// Passed to `InfoStrategyArrayLoader`'s `LoadStrategy` to provide context for the page being loaded.
public enum InfoLoadRequest<Element, Info>: LoadRequestType
{
    // MARK: - Cases
    
    /**
     A load request for the next page of the array.
     
     - parameter current: The current contents of the array.
     - parameter info:    The current info value for the next page.
     */
    case Next(current: [Element], info: Info)
    
    /**
     A load request for the previous page of the array.
     
     - parameter current: The current contents of the array.
     - parameter info:    The current info value for the previous page.
     */
    case Previous(current: [Element], info: Info)
    
    // MARK: - Properties
    
    /// Discards the `info` value, and returns a `LoadRequest` representation.
    public var loadRequest: LoadRequest<Element>
    {
        switch self
        {
        case .Next(let tuple):
            return .Next(current: tuple.0)
        case .Previous(let tuple):
            return .Previous(current: tuple.0)
        }
    }
    
    /// Returns `true` if the load request is `.Next`.
    public var isNext: Bool
    {
        switch self
        {
        case .Next:
            return true
        case .Previous:
            return false
        }
    }
    
    /// The current contents of the array loader.
    public var current: [Element]
    {
        switch self
        {
        case .Next(let tuple):
            return tuple.0
        case .Previous(let tuple):
            return tuple.0
        }
    }
    
    /// The current info for the page type of the array loader.
    public var info: Info
    {
        switch self
        {
        case .Next(let tuple):
            return tuple.1
        case .Previous(let tuple):
            return tuple.1
        }
    }
}
