//
//  LinkedListQueueTests.swift
//  QueueApp
//

import Testing
@testable import QueueApp

@Suite("LinkedListQueue Tests")
struct LinkedListQueueTests {

    @Test("Queue is empty upon initialization")
    func testQueueIsEmptyInitially() {
        let queue = LinkedListQueue<Int>()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek == nil)
    }

    @Test("Enqueuing an element")
    func testEnqueue() throws {
        let queue = LinkedListQueue<String>()
        try queue.enqueue("First")
        #expect(!queue.isEmpty)
        #expect(queue.count == 1)
        #expect(queue.peek == "First")

        try queue.enqueue("Second")
        #expect(queue.count == 2)
        #expect(queue.peek == "First")
    }

    @Test("Dequeuing an element")
    func testDequeue() throws {
        let queue = LinkedListQueue<Int>()
        try queue.enqueue(10)
        try queue.enqueue(20)

        let firstElement = queue.dequeue()
        #expect(firstElement == 10)
        #expect(queue.count == 1)
        #expect(queue.peek == 20)

        let secondElement = queue.dequeue()
        #expect(secondElement == 20)
        #expect(queue.count == 0)
        #expect(queue.isEmpty)
        #expect(queue.peek == nil)

        let elementFromEmptyQueue = queue.dequeue()
        #expect(elementFromEmptyQueue == nil)
    }

    @Test("Clearing the queue")
    func testClear() throws {
        let queue = LinkedListQueue<Character>()
        try queue.enqueue("X")
        try queue.enqueue("Y")
        #expect(queue.count == 2)

        queue.clear()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek == nil)
    }

    @Test("Limited capacity queue - successful enqueue")
    func testLimitedCapacityEnqueueSuccess() throws {
        let queue = LinkedListQueue<Double>(capacity: 3)
        try queue.enqueue(1.1)
        try queue.enqueue(2.2)
        #expect(queue.count == 2)
        #expect(queue.peek == 1.1)
    }

    @Test("Limited capacity queue - exceeding capacity")
    func testLimitedCapacityEnqueueFailure() throws {
        let queue = LinkedListQueue<String>(capacity: 2)
        try queue.enqueue("A")
        try queue.enqueue("B")
        #expect(queue.count == 2)

        #expect(throws: QueueError.capacityExceeded) {
            try queue.enqueue("C")
        }
        #expect(queue.count == 2)
        #expect(queue.peek == "A")
    }

    @Test("Limited capacity queue - clearing and re-enqueuing")
    func testLimitedCapacityClearAndReEnqueue() throws {
        let queue = LinkedListQueue<Int>(capacity: 1)
        try queue.enqueue(1)
        #expect(queue.count == 1)

        #expect(throws: QueueError.capacityExceeded) {
            try queue.enqueue(2)
        }

        let dequeuedElement = queue.dequeue()
        #expect(dequeuedElement == 1)
        #expect(queue.isEmpty)

        try queue.enqueue(3)
        #expect(queue.count == 1)
        #expect(queue.peek == 3)
    }
}
