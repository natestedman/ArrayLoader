// ArrayLoader
// Written in 2016 by Nate Stedman <nate@natestedman.com>
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
import enum Result.NoError

class StrategyArrayLoaderTests: XCTestCase
{
    func testLoadNextPage()
    {
        let arrayLoader = StrategyArrayLoader<Int, NoError> { request in
            SignalProducer(value: LoadResult(
                elements: [request.current.count],
                nextPageHasMore: request.current.count == 1 ? .Replace(false) : .DoNotReplace,
                previousPageHasMore: .DoNotReplace
            ))
        }

        XCTAssertEqual(arrayLoader.elements.value, [])
        XCTAssertEqual(arrayLoader.nextPageState.value, PageState.HasMore)

        arrayLoader.loadNextPage()
        XCTAssertEqual(arrayLoader.elements.value, [0])
        XCTAssertEqual(arrayLoader.nextPageState.value, PageState.HasMore)

        arrayLoader.loadNextPage()
        XCTAssertEqual(arrayLoader.elements.value, [0, 1])
        XCTAssertEqual(arrayLoader.nextPageState.value, PageState.Completed)
    }

    func testLoaderEvents()
    {
        let arrayLoader = StrategyArrayLoader<Int, NoError> { request in
            SignalProducer(value: LoadResult(elements: [request.isNext ? 1 : 0]))
        }

        let events = AnyProperty<[LoaderEvent<Int, NoError>]>(
            initialValue: [],
            producer: arrayLoader.events.scan([], { $0 + [$1] })
        )

        XCTAssertEqual(events.value.count, 1)
        XCTAssertTrue(events.value[0].isCurrent)
        XCTAssertEqual(events.value[0].state.elements, [])

        arrayLoader.loadNextPage()
        XCTAssertEqual(events.value.count, 2)
        XCTAssertTrue(events.value[1].isNextPageLoaded)
        XCTAssertEqual(events.value[1].state.elements, [1])
        XCTAssertEqual(events.value[1].newElements ?? [], [1])

        arrayLoader.loadPreviousPage()
        XCTAssertEqual(events.value.count, 3)
        XCTAssertTrue(events.value[2].isPreviousPageLoaded)
        XCTAssertEqual(events.value[2].state.elements, [0, 1])
        XCTAssertEqual(events.value[2].newElements ?? [], [0])
    }
}
