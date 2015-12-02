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

class InfoLoadRequestTests: XCTestCase
{
    func testNext()
    {
        let request = InfoLoadRequest<Int, Int>.Next(current: [], info: 0)
        XCTAssertTrue(request.isNext)
        XCTAssertFalse(request.isPrevious)
    }
    
    func testPrevious()
    {
        let request = InfoLoadRequest<Int, Int>.Previous(current: [], info: 0)
        XCTAssertTrue(request.isPrevious)
        XCTAssertFalse(request.isNext)
    }
    
    func testCurrent()
    {
        let previous = InfoLoadRequest<Int, Int>.Previous(current: [0, 1, 2, 3], info: 0)
        XCTAssertEqual(previous.current, [0, 1, 2, 3])
        
        let next = InfoLoadRequest<Int, Int>.Previous(current: [0, 1, 2, 3], info: 0)
        XCTAssertEqual(next.current, [0, 1, 2, 3])
    }
    
    func testInfo()
    {
        let previous = InfoLoadRequest<Int, Int>.Next(current: [], info: 10)
        XCTAssertEqual(previous.info, 10)
        
        let next = InfoLoadRequest<Int, Int>.Next(current: [], info: 10)
        XCTAssertEqual(next.info, 10)
    }
}
