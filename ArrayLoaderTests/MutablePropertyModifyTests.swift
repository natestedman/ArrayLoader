// ArrayLoader
// Written in 2017 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

@testable import ArrayLoader
import ReactiveSwift
import XCTest

final class MutablePropertyModifyTests: XCTestCase
{
    func testPropertyModified()
    {
        let property = MutableProperty(0)
        property.modifyOld({ $0 + 1 })
        XCTAssertEqual(property.value, 1)
    }

    func testOldValueReturned()
    {
        let property = MutableProperty(0)
        XCTAssertEqual(property.modifyOld({ $0 + 1 }), 0)
    }
}
