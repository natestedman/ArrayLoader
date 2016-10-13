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
        let loader = StaticArrayLoader<Int>(elements: [])
        
        XCTAssertEqual(loader.nextPageState, PageState.Completed)
        XCTAssertEqual(loader.previousPageState, PageState.Completed)
        XCTAssertEqual(loader.elements, [])
    }
    
    func testContent()
    {
        let loader = StaticArrayLoader<Int>(elements: [0, 1, 2, 3, 4])
        
        XCTAssertTrue(loader.nextPageState.isCompleted)
        XCTAssertTrue(loader.previousPageState.isCompleted)
        XCTAssertEqual(loader.elements, [0, 1, 2, 3, 4])
    }
    
    func testEmptyArrayLoader()
    {
        let loader = StaticArrayLoader<Int>.empty
        
        XCTAssertEqual(loader.elements, [])
        XCTAssertTrue(loader.nextPageState.isCompleted)
        XCTAssertTrue(loader.previousPageState.isCompleted)
    }
}
