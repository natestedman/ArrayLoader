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

class DerivedPropertyTests: XCTestCase
{
    var strongProperty: DerivedProperty<Int>?
    weak var weakProperty: DerivedProperty<Int>?
    
    override func setUp()
    {
        strongProperty = DerivedProperty(wrapped: AnyProperty(initialValue: 0, producer: SignalProducer.never))
        weakProperty = strongProperty
    }
    
    func testNoProducerRetain()
    {
        // should deallocate when not strongly referenced
        XCTAssertNotNil(weakProperty)
        strongProperty = nil
        XCTAssertNil(weakProperty)
    }
    
    func testProducerRetain()
    {
        // should not deallocate if a producer is referenced
        XCTAssertNotNil(weakProperty)
        var producer = strongProperty?.producer
        XCTAssertNotNil(producer)
        
        strongProperty = nil
        XCTAssertNotNil(weakProperty)
        
        // once producer is dereferenced, should deallocate
        producer = nil
        XCTAssertNil(weakProperty)
    }
}
