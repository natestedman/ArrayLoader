// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import ArrayLoader
import XCTest

class PageStateTests: XCTestCase
{
    func testHasMore()
    {
        XCTAssertTrue(PageState<NSError>.hasMore.isHasMore)
        XCTAssertFalse(PageState<NSError>.hasMore.isCompleted)
        XCTAssertFalse(PageState<NSError>.hasMore.isLoading)
        XCTAssertNil(PageState<NSError>.hasMore.error)
    }
    
    func testCompleted()
    {
        XCTAssertTrue(PageState<NSError>.completed.isCompleted)
        XCTAssertFalse(PageState<NSError>.completed.isHasMore)
        XCTAssertFalse(PageState<NSError>.completed.isLoading)
        XCTAssertNil(PageState<NSError>.completed.error)
    }
    
    func testLoading()
    {
        XCTAssertTrue(PageState<NSError>.loading.isLoading)
        XCTAssertFalse(PageState<NSError>.loading.isCompleted)
        XCTAssertFalse(PageState<NSError>.loading.isHasMore)
        XCTAssertNil(PageState<NSError>.loading.error)
    }
    
    func testFailure()
    {
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.failed(testError)
        
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isCompleted)
        XCTAssertFalse(state.isLoading)
        XCTAssertNotNil(state.error)
        XCTAssertEqual(state.error, testError)
    }
    
    func testEquatable()
    {
        XCTAssertEqual(PageState<NSError>.loading, PageState.loading)
        XCTAssertEqual(PageState<NSError>.completed, PageState.completed)
        XCTAssertEqual(PageState<NSError>.hasMore, PageState.hasMore)
        
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.failed(testError)
        XCTAssertEqual(state, state)
        
        let otherError = NSError(domain: "test", code: 1, userInfo: nil)
        XCTAssertNotEqual(state, PageState.failed(otherError))
    }
}
