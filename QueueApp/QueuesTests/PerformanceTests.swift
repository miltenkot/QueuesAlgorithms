//
//  PerformanceTests.swift
//  QueuesTests
//

import XCTest
@testable import QueueApp

final class TestPerformanceTests: XCTestCase {
    let count = 100_000
    
    func testPerformanceOfArrayQueue() throws {
        measure {
            var q = ArrayQueue<String>()
            for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
            for _ in 0..<count { _ = q.dequeue() }
        }
    }
    
    func testPerformanceOfLinkedListQueue() throws {
        measure {
            let q = LinkedListQueue<String>()
            for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
            for _ in 0..<count { _ = q.dequeue() }
        }
    }
    
    func testPerformanceOfRingBufferQueue() throws {
        measure {
            let q = RingBufferQueue<String>(count: count)
            for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
            for _ in 0..<count { _ = q.dequeue() }
        }
    }
    
    func testPerformanceOfDoubleStackQueue() throws {
        measure {
            let q = DoubleStackQueue<String>()
            for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
            for _ in 0..<count { _ = q.dequeue() }
        }
    }
}
