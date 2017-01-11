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
import XCTest

class LoadRequestTests: XCTestCase
{
    func testNext()
    {
        let request = LoadRequest<Int>.next(current: [])
        XCTAssertTrue(request.isNext)
        XCTAssertFalse(request.isPrevious)
    }
    
    func testPrevious()
    {
        let request = LoadRequest<Int>.previous(current: [])
        XCTAssertTrue(request.isPrevious)
        XCTAssertFalse(request.isNext)
    }
    
    func testCurrent()
    {
        let previous = LoadRequest<Int>.previous(current: [0, 1, 2, 3])
        XCTAssertEqual(previous.current, [0, 1, 2, 3])
        
        let next = LoadRequest<Int>.previous(current: [0, 1, 2, 3])
        XCTAssertEqual(next.current, [0, 1, 2, 3])
    }
}
