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
        let wrapped = StaticArrayLoader(elements: [0, 1, 2, 3, 4], pageSize: 2)
        let any = AnyArrayLoader(wrapped)
        
        // check that initial state matches
        XCTAssertTrue(wrapped.state.value == any.state.value, "\(wrapped.state.value) should equal \(any.state.value)")
        
        // load the first page
        wrapped.loadNextPage()
        XCTAssertTrue(wrapped.state.value == any.state.value, "\(wrapped.state.value) should equal \(any.state.value)")
        
        // load the second page
        any.loadNextPage()
        XCTAssertTrue(wrapped.state.value == any.state.value, "\(wrapped.state.value) should equal \(any.state.value)")
        
        // load the final page
        wrapped.loadNextPage()
        XCTAssertTrue(wrapped.state.value == any.state.value, "\(wrapped.state.value) should equal \(any.state.value)")
    }
}
