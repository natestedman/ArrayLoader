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
import Result

/// Loads data synchronously from a static backing array.
public struct StaticArrayLoader<Element>
{
    // MARK: - Initialization
    
    /**
    Initializes a static array loader.
    
    - parameter elements: The array of backing elements to use.
    - parameter pageSize: The page size to use.
    */
    public init(elements: [Element], pageSize: Int)
    {
        self.backingElements = elements
        self.pageSize = pageSize
        
        // create the offset property in the initializer so that we can use it to initialize other properties
        let offset = MutableProperty<Int>(0)
        self.offset = offset
        
        // transform the offset into the current state
        let stateForOffset = { (offset: Int) -> LoaderState<Element, Error> in
            let slice = Array<Element>(elements[0..<offset])
            
            return LoaderState(
                elements: slice,
                nextPageState: offset < elements.count ? .HasMore : .Completed,
                previousPageState: .Completed
            )
        }
        
        self.state = AnyProperty(
            initialValue: stateForOffset(offset.value),
            producer: offset.producer.skip(1).map(stateForOffset)
        )
    }
    
    // MARK: - Backing Data
    
    /// The backing elements.
    let backingElements: [Element]
    
    /// The page size to use.
    let pageSize: Int
    
    // MARK: - State
    
    /// The current offset within `elements`.
    let offset: MutableProperty<Int>
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>
}

extension StaticArrayLoader
{
    // MARK: - Empty
    
    /// Returns an empty array loader, with both next and previous pages completed.
    public static var empty: StaticArrayLoader<Element> {
        return StaticArrayLoader(elements: [], pageSize: 0)
    }
}

// MARK: - ArrayLoader
extension StaticArrayLoader: ArrayLoader
{
    // MARK: - Typealiases
    public typealias Error = NoError
    
    // MARK: - Loading Elements
    
    /// Instructs the array loader to load its next page. If the next page is already loading, or there is not a next
    /// page, this function does nothing.
    public func loadNextPage()
    {
        offset.value = min(offset.value + pageSize, backingElements.count)
    }
    
    /// Instructs the array loader to load the previous page. `StaticArrayLoader` does not support previous pages, so
    /// this function does nothing.
    public func loadPreviousPage()
    {
    }
}
