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
        XCTAssertTrue(PageState<NSError>.HasMore.isHasMore)
        XCTAssertFalse(PageState<NSError>.HasMore.isCompleted)
        XCTAssertFalse(PageState<NSError>.HasMore.isLoading)
        XCTAssertNil(PageState<NSError>.HasMore.error)
    }
    
    func testCompleted()
    {
        XCTAssertTrue(PageState<NSError>.Completed.isCompleted)
        XCTAssertFalse(PageState<NSError>.Completed.isHasMore)
        XCTAssertFalse(PageState<NSError>.Completed.isLoading)
        XCTAssertNil(PageState<NSError>.Completed.error)
    }
    
    func testLoading()
    {
        XCTAssertTrue(PageState<NSError>.Loading.isLoading)
        XCTAssertFalse(PageState<NSError>.Loading.isCompleted)
        XCTAssertFalse(PageState<NSError>.Loading.isHasMore)
        XCTAssertNil(PageState<NSError>.Loading.error)
    }
    
    func testFailure()
    {
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.Failed(testError)
        
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isCompleted)
        XCTAssertFalse(state.isLoading)
        XCTAssertNotNil(state.error)
        XCTAssertEqual(state.error, testError)
    }
    
    func testEquatable()
    {
        XCTAssertEqual(PageState<NSError>.Loading, PageState.Loading)
        XCTAssertEqual(PageState<NSError>.Completed, PageState.Completed)
        XCTAssertEqual(PageState<NSError>.HasMore, PageState.HasMore)
        
        let testError = NSError(domain: "test", code: 0, userInfo: nil)
        let state = PageState.Failed(testError)
        XCTAssertEqual(state, state)
        
        let otherError = NSError(domain: "test", code: 1, userInfo: nil)
        XCTAssertNotEqual(state, PageState.Failed(otherError))
    }
}
