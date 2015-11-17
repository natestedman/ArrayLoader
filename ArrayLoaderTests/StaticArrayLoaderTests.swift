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
import XCTest

class StaticArrayLoaderTests: XCTestCase
{
    func testEmpty()
    {
        let loader = StaticArrayLoader<Int>(elements: [], pageSize: 10)
        
        XCTAssertEqual(loader.nextPageState.value, PageState.Completed)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [])
    }
    
    func testPartialPage()
    {
        let loader = StaticArrayLoader<Int>(elements: [0, 1, 2, 3, 4], pageSize: 10)
        
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [])
        
        loader.loadNextPage()
        
        XCTAssertTrue(loader.nextPageState.value.isCompleted)
        XCTAssertTrue(loader.previousPageState.value.isCompleted)
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3, 4])
    }
    
    func testCompletePage()
    {
        let loader = StaticArrayLoader<Int>(elements: [0, 1, 2, 3, 4], pageSize: 5)
        
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [])
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.nextPageState.value, PageState.Completed)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3, 4])
    }
    
    func testMultiplePages()
    {
        let loader = StaticArrayLoader<Int>(elements: [0, 1, 2, 3, 4], pageSize: 2)
        
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [])
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [0, 1])
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.nextPageState.value, PageState.HasMore)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3])
        
        loader.loadNextPage()
        
        XCTAssertEqual(loader.nextPageState.value, PageState.Completed)
        XCTAssertEqual(loader.previousPageState.value, PageState.Completed)
        XCTAssertEqual(loader.elements.value, [0, 1, 2, 3, 4])
    }
}
