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

        XCTAssertEqual(loader.state.value.elements, loader.elements)
        XCTAssertEqual(loader.state.value.nextPageState, loader.nextPageState)
        XCTAssertEqual(loader.state.value.previousPageState, loader.previousPageState)
    }
}
