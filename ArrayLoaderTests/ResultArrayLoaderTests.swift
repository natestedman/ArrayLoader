// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

@testable import ArrayLoader
import ReactiveCocoa
import Result
import XCTest

class ResultArrayLoaderTests: XCTestCase
{
    func testEmpty()
    {
        let loader = ResultArrayLoader<Int, NoError>(nextResults: [], previousResults: [])
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
    
    func testBoth()
    {
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        
        let loader = ResultArrayLoader<Int, NSError>(
            nextResults: [
                Result.Success([0, 1, 2]),
                Result.Failure(error),
                Result.Success([3, 4]),
            ],
            previousResults: [
                Result.Success([-2, -1]),
                Result.Failure(error),
                Result.Success([-4, -3])
            ]
        )
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [-2, -1, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [-2, -1, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Failed(error))
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [-2, -1, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Failed(error))
        XCTAssertEqual(loader.previousPageState.value, PageState.Failed(error))
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [-2, -1, 0, 1, 2, 3, 4])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Failed(error))
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [-4, -3, -2, -1, 0, 1, 2, 3, 4])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
    
    func testNext()
    {
        let loader = ResultArrayLoader<Int, NoError>(
            nextResults: [
                Result.Success([0, 1, 2]),
                Result.Success([3]),
                Result.Success([4, 5])
            ],
            previousResults: []
        )
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
    
    func testNextErrors()
    {
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        
        let loader = ResultArrayLoader<Int, NSError>(
            nextResults: [
                Result.Success([0, 1, 2]),
                Result.Failure(error),
                Result.Success([4, 5])
            ],
            previousResults: []
        )
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Failed(error))
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 4, 5])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
    
    func testPrevious()
    {
        let loader = ResultArrayLoader<Int, NoError>(
            nextResults: [],
            previousResults: [
                Result.Success([0, 1, 2]),
                Result.Success([3]),
                Result.Success([4, 5])
            ]
        )
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [3, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [4, 5, 3, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
    
    func testPreviousErrors()
    {
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        
        let loader = ResultArrayLoader<Int, NSError>(
            nextResults: [],
            previousResults: [
                Result.Success([0, 1, 2]),
                Result.Failure(error),
                Result.Success([4, 5])
            ]
        )
        
        XCTAssertEqual(loader.elements.value, [])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.HasMore)
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Failed(error))
        
        loader.loadPreviousPage()
        
        XCTAssertEqual(loader.elements.value, [4, 5, 0, 1, 2])
        XCTAssertEqual(loader.nextPageState.value, PageState.Complete)
        XCTAssertEqual(loader.previousPageState.value, PageState.Complete)
    }
}
