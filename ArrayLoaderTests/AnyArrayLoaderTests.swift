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

class AnyArrayLoaderTests: XCTestCase
{
    func testMatchesStatic()
    {
        let wrapped = StaticArrayLoader(elements: [0, 1, 2, 3, 4])
        let any = AnyArrayLoader(wrapped)

        XCTAssertTrue(wrapped.state.value == any.state.value)
    }
}
