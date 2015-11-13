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

class LoaderStateTests: XCTestCase
{
    func testEquality()
    {
        XCTAssertTrue(
            LoaderState<Int, NoError>(elements: [], nextPageState: .HasMore, previousPageState: .Complete) ==
            LoaderState<Int, NoError>(elements: [], nextPageState: .HasMore, previousPageState: .Complete)
        )
        
        XCTAssertTrue(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .Complete) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .Complete)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .Complete) ==
            LoaderState<Int, NoError>(elements: [1, 2], nextPageState: .HasMore, previousPageState: .Complete)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .Complete) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .HasMore)
        )
        
        XCTAssertFalse(
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .HasMore, previousPageState: .Complete) ==
            LoaderState<Int, NoError>(elements: [1, 2, 3], nextPageState: .Complete, previousPageState: .Complete)
        )
    }
}
