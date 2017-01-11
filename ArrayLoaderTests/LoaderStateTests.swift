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
import ReactiveSwift
import Result
import XCTest

class LoaderStateTests: XCTestCase
{
    func testEquality()
    {
        XCTAssertTrue(
            LoaderState<Int, NoError>(elements: [], nextPageState: .hasMore, previousPageState: .completed) ==
            LoaderState<Int, NoError>(elements: [], nextPageState: .hasMore, previousPageState: .completed)
        )
        
        XCTAssertTrue(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .completed) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .completed)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .completed) ==
            LoaderState<Int, NoError>(elements: [1, 2], nextPageState: .hasMore, previousPageState: .completed)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .completed) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .hasMore)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .hasMore, previousPageState: .completed) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .completed, previousPageState: .completed)
        )
    }
}
