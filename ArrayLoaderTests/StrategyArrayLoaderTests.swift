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

        XCTAssertEqual(arrayLoader.elements, [])
        XCTAssertEqual(arrayLoader.nextPageState, PageState.HasMore)

        arrayLoader.loadNextPage()
        XCTAssertEqual(arrayLoader.elements, [0])
        XCTAssertEqual(arrayLoader.nextPageState, PageState.HasMore)

        arrayLoader.loadNextPage()
        XCTAssertEqual(arrayLoader.elements, [0, 1])
        XCTAssertEqual(arrayLoader.nextPageState, PageState.Completed)
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
        XCTAssertEqual(events.value.count, 3)
        XCTAssertTrue(events.value[1].isNextPageLoading)
        XCTAssertEqual(events.value[1].state.elements, [])
        XCTAssertTrue(events.value[2].isNextPageLoaded)
        XCTAssertEqual(events.value[2].state.elements, [1])
        XCTAssertEqual(events.value[2].newElements ?? [], [1])

        arrayLoader.loadPreviousPage()
        XCTAssertEqual(events.value.count, 5)
        XCTAssertTrue(events.value[3].isPreviousPageLoading)
        XCTAssertEqual(events.value[3].state.elements, [1])
        XCTAssertTrue(events.value[4].isPreviousPageLoaded)
        XCTAssertEqual(events.value[4].state.elements, [0, 1])
        XCTAssertEqual(events.value[4].newElements ?? [], [0])
    }

    func testLoaderFailureEvents()
    {
        let error = NSError(domain: "test", code: 0, userInfo: nil)

        let arrayLoader = StrategyArrayLoader<Int, NSError> { _ in SignalProducer(error: error) }

        let events = AnyProperty<[LoaderEvent<Int, NSError>]>(
            initialValue: [],
            producer: arrayLoader.events.scan([], { $0 + [$1] })
        )

        XCTAssertEqual(events.value.count, 1)
        XCTAssertTrue(events.value[0].isCurrent)
        XCTAssertEqual(events.value[0].state.elements, [])

        arrayLoader.loadNextPage()
        XCTAssertEqual(events.value.count, 3)
        XCTAssertTrue(events.value[1].isNextPageLoading)
        XCTAssertEqual(events.value[1].state.elements, [])
        XCTAssertTrue(events.value[2].isNextPageFailed)
        XCTAssertEqual(events.value[2].state.elements, [])
        XCTAssertEqual(events.value[2].state.nextPageState.error, error)

        arrayLoader.loadPreviousPage()
        XCTAssertEqual(events.value.count, 5)
        XCTAssertTrue(events.value[3].isPreviousPageLoading)
        XCTAssertEqual(events.value[3].state.elements, [])
        XCTAssertTrue(events.value[4].isPreviousPageFailed)
        XCTAssertEqual(events.value[4].state.elements, [])
        XCTAssertEqual(events.value[4].state.previousPageState.error, error)
    }
}
