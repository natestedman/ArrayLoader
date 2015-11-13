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
        XCTAssertTrue(PageState<NSError>.HasMore.hasMore)
        XCTAssertFalse(PageState<NSError>.HasMore.complete)
        XCTAssertFalse(PageState<NSError>.HasMore.loading)
        XCTAssertNil(PageState<NSError>.HasMore.error)
    }
    
    func testComplete()
    {
        XCTAssertTrue(PageState<NSError>.Complete.complete)
        XCTAssertFalse(PageState<NSError>.Complete.hasMore)
        XCTAssertFalse(PageState<NSError>.Complete.loading)
        XCTAssertNil(PageState<NSError>.Complete.error)
    }
    
    func testLoading()
    {
        XCTAssertTrue(PageState<NSError>.Loading.loading)
        XCTAssertFalse(PageState<NSError>.Loading.complete)
        XCTAssertFalse(PageState<NSError>.Loading.hasMore)
        XCTAssertNil(PageState<NSError>.Loading.error)
    }
    
    func testFailure()
    {
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.Failed(testError)
        
        XCTAssertFalse(state.loading)
        XCTAssertFalse(state.complete)
        XCTAssertFalse(state.loading)
        XCTAssertNotNil(state.error)
        XCTAssertEqual(state.error, testError)
    }
    
    func testEquatable()
    {
        XCTAssertEqual(PageState<NSError>.Loading, PageState.Loading)
        XCTAssertEqual(PageState<NSError>.Complete, PageState.Complete)
        XCTAssertEqual(PageState<NSError>.HasMore, PageState.HasMore)
        
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.Failed(testError)
        XCTAssertEqual(state, state)
        
        let otherError = NSError(domain: "test", code: 1, userInfo: nil)
        XCTAssertNotEqual(state, PageState.Failed(otherError))
    }
}
