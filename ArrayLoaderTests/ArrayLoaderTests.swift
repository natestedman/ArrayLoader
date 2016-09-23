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

class ArrayLoaderTests: XCTestCase
{
    func testValuesMatch()
    {
        let loader = StaticArrayLoader(elements: [0, 1, 2, 3, 4])

        XCTAssertEqual(loader.state.value.elements, loader.elements.value)
        XCTAssertEqual(loader.state.value.nextPageState, loader.nextPageState.value)
        XCTAssertEqual(loader.state.value.previousPageState, loader.previousPageState.value)
    }
    
    func testPropertyBinding()
    {
        let loader = StrategyArrayLoader<Int, NoError>(load: { request in
            SignalProducer(value: LoadResult(elements: [0]))
        })
        
        let elements = MutableProperty<[Int]>([])
        elements <~ loader.elements.producer
        
        let nextPage = MutableProperty<PageState<NoError>>(.HasMore)
        nextPage <~ loader.nextPageState.producer
        
        XCTAssertEqual(loader.elements.value, elements.value)
        XCTAssertEqual(loader.nextPageState.value, nextPage.value)
        
        loader.loadNextPage()
        XCTAssertEqual(loader.elements.value, elements.value)
        XCTAssertEqual(loader.nextPageState.value, nextPage.value)
        
        loader.loadNextPage()
        XCTAssertEqual(loader.elements.value, elements.value)
        XCTAssertEqual(loader.nextPageState.value, nextPage.value)
        
        loader.loadNextPage()
        XCTAssertEqual(loader.elements.value, elements.value)
        XCTAssertEqual(loader.nextPageState.value, nextPage.value)
    }
}
