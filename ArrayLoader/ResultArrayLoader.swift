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

/// Loads array content synchronously from two arrays of `Result` values.
///
/// Each `loadNextPage()` and `loadPreviousPage()` call will advance the index of the associated array by one. Each
/// error value will only occur once, so loading the page again will advance past the error.
public final class ResultArrayLoader<Element, Error: ErrorType>
{
    // MARK: - Initialization
    
    /**
    Initializes a result array loader.
    
    - parameter nextResults:     The array of results to use for `loadNextPage()` calls.
    - parameter previousResults: The array of results to use for `loadPreviousPage()` calls.
    */
    public init(nextResults: [Result<[Element], Error>], previousResults: [Result<[Element], Error>])
    {
        self.nextResults = nextResults
        self.previousResults = previousResults
        
        // create the offset properties in the initializer so that we can use them to initialize other properties
        let nextOffset = MutableProperty(0)
        self.nextOffset = nextOffset
        
        let previousOffset = MutableProperty(0)
        self.previousOffset = previousOffset
        
        // transform the offsets to produce the current loader state
        let pageState = { (array: [Result<[Element], Error>], offset: Int) -> PageState<Error> in
            if offset == array.count
            {
                return .Completed
            }
            else if offset == 0
            {
                return .HasMore
            }
            else
            {
                switch array[offset - 1]
                {
                case .Success:
                    return .HasMore
                case .Failure(let error):
                    return .Failed(error)
                }
            }
        }
        
        let stateForOffsets = { (nextOffset: Int, previousOffset: Int) -> LoaderState<Element, Error> in
            // combine arrays up to the current offsets
            let next = nextResults[0..<nextOffset].flatMap({ result in result.value ?? [] })
            let previous = previousResults[0..<previousOffset].reverse().flatMap({ result in result.value ?? []})
            
            return LoaderState(
                elements: previous + next,
                nextPageState: pageState(nextResults, nextOffset),
                previousPageState: pageState(previousResults, previousOffset)
            )
        }
        
        self.state = AnyProperty(
            initialValue: stateForOffsets(nextOffset.value, previousOffset.value),
            producer: combineLatest(nextOffset.producer, previousOffset.producer).skip(1).map(stateForOffsets)
        )
    }
    
    // MARK: - Offsets
    
    /// The current offset for the `nextResults` array.
    let nextOffset: MutableProperty<Int>
    
    /// The current offset for the `previousResults` array.
    let previousOffset: MutableProperty<Int>
    
    // MARK: - Results
    
    /// The array of results to be appended when next pages are loaded.
    let nextResults: [Result<[Element], Error>]
    
    /// The array of results to be prepended when next pages are loaded.
    let previousResults: [Result<[Element], Error>]
    
    // MARK: - State
    
    /// The current state of the array loader.
    public let state: AnyProperty<LoaderState<Element, Error>>
}

// MARK: - ArrayLoader
extension ResultArrayLoader: ArrayLoader
{
    // MARK: - Loading Elements
    
    /// Instructs the array loader to load its next page. If there are no more next pages, this function does nothing.
    public func loadNextPage()
    {
        nextOffset.value = min(nextOffset.value + 1, nextResults.count)
    }
    
    /// Instructs the array loader to load the previous page. If there are no more previous pages, this function does
    /// nothing.
    public func loadPreviousPage()
    {
        previousOffset.value = min(previousOffset.value + 1, previousResults.count)
    }
}
