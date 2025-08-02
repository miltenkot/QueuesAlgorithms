//
//  RingBufferQueueTests.swift
//  QueueApp
//

import Testing
@testable import QueueApp

@Suite("RingBufferQueue Tests")
struct RingBufferQueueTests {

    @Test("Queue is empty upon initialization")
    func testQueueIsEmptyInitially() {
        let queue = RingBufferQueue<Int>(count: 10)
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek == nil)
    }

    @Test("Enqueuing an element")
    func testEnqueue() throws {
        let queue = RingBufferQueue<String>(count: 10)
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
        let queue = RingBufferQueue<Int>(count: 10)
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
        let queue = RingBufferQueue<Character>(count: 10)
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
        let queue = RingBufferQueue<Double>(count: 3)
        try queue.enqueue(1.1)
        try queue.enqueue(2.2)
        #expect(queue.count == 2)
        #expect(queue.peek == 1.1)
    }

    @Test("Limited capacity queue - exceeding capacity")
    func testLimitedCapacityEnqueueFailure() throws {
        let queue = RingBufferQueue<String>(count: 2)
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
        let queue = RingBufferQueue<Int>(count: 1)
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

@Suite("RingBuffer Specific Tests")
struct RingBufferTests {

    @Test("Buffer is empty and not full upon initialization")
    func testBufferInitialState() {
        let buffer = RingBuffer<Int>(count: 5)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
        #expect(buffer.count == 0)
        #expect(buffer.first == nil)
        #expect(buffer.description == "[]")
    }

    @Test("Writing elements and checking state")
    func testBufferWriteOperations() throws {
        var buffer = RingBuffer<String>(count: 3)

        try buffer.write("Apple")
        #expect(buffer.count == 1)
        #expect(buffer.isEmpty == false)
        #expect(buffer.isFull == false)
        #expect(buffer.first == "Apple")
        #expect(buffer.description == "[Apple]")

        try buffer.write("Banana")
        #expect(buffer.count == 2)
        #expect(buffer.description == "[Apple, Banana]")

        try buffer.write("Cherry")
        #expect(buffer.count == 3)
        #expect(buffer.isFull)
        #expect(buffer.description == "[Apple, Banana, Cherry]")
    }

    @Test("Reading elements and checking state")
    func testBufferReadOperations() throws {
        var buffer = RingBuffer<Int>(count: 3)
        try buffer.write(10)
        try buffer.write(20)
        try buffer.write(30) // Buffer: [10, 20, 30]

        let val1 = buffer.read()
        #expect(val1 == 10)
        #expect(buffer.count == 2)
        #expect(buffer.isEmpty == false)
        #expect(buffer.isFull == false)
        #expect(buffer.first == 20)
        #expect(buffer.description == "[20, 30]")

        let val2 = buffer.read()
        #expect(val2 == 20)
        #expect(buffer.count == 1)
        #expect(buffer.first == 30)
        #expect(buffer.description == "[30]")

        let val3 = buffer.read()
        #expect(val3 == 30)
        #expect(buffer.count == 0)
        #expect(buffer.isEmpty)
        #expect(buffer.first == nil)
        #expect(buffer.description == "[]")
    }

    @Test("Writing to a full buffer throws `bufferFull` error")
    func testWriteToFullBufferThrows() throws {
        var buffer = RingBuffer<Double>(count: 2)
        try buffer.write(1.1)
        try buffer.write(2.2)
        #expect(buffer.isFull)

        #expect(throws: RingBufferError.bufferFull) {
            try buffer.write(3.3)
        }
        #expect(buffer.count == 2) // Count should not change
        #expect(buffer.description == "[1.1, 2.2]")
    }

    @Test("Reading from an empty buffer returns nil")
    func testReadFromEmptyBufferReturnsNil() {
        var buffer = RingBuffer<Bool>(count: 5)
        let element = buffer.read()
        #expect(element == nil)
        #expect(buffer.isEmpty)
        #expect(buffer.count == 0)
    }

    @Test("Buffer wrap-around functionality")
    func testBufferWrapAround() throws {
        var buffer = RingBuffer<Int>(count: 3) // Capacity 3

        // Fill buffer
        try buffer.write(1) // [1, nil, nil]
        try buffer.write(2) // [1, 2, nil]
        try buffer.write(3) // [1, 2, 3] - Full
        #expect(buffer.isFull)
        #expect(buffer.description == "[1, 2, 3]")

        // Read one, write one (should wrap)
        let r1 = buffer.read() // Read 1 -> [nil, 2, 3]
        #expect(r1 == 1)
        #expect(buffer.isFull == false) // No longer full
        #expect(buffer.description == "[2, 3]") // Shows current elements correctly

        try buffer.write(4) // Write 4 -> [4, 2, 3] (conceptually) but readIndex moves to 2, writeIndex moves to 4, array is [4,2,3] with internal representation
        #expect(buffer.isFull)
        #expect(buffer.count == 3)
        #expect(buffer.first == 2) // First element is now at array[readIndex % count]
        #expect(buffer.description == "[2, 3, 4]")

        // Continue reading and writing to ensure wrap-around is smooth
        let r2 = buffer.read() // Read 2 -> [nil, nil, 3]
        #expect(r2 == 2)
        #expect(buffer.count == 2)
        #expect(buffer.first == 3)

        try buffer.write(5) // Write 5 -> [5, nil, 3]
        #expect(buffer.count == 3)
        #expect(buffer.first == 3)
        #expect(buffer.description == "[3, 4, 5]") // Check visual representation

        let r3 = buffer.read() // Read 3
        #expect(r3 == 3)
        let r4 = buffer.read() // Read 4
        #expect(r4 == 4)
        let r5 = buffer.read() // Read 5
        #expect(r5 == 5)
        #expect(buffer.isEmpty)
        #expect(buffer.description == "[]")
    }

    @Test("Clearing the buffer resets state")
    func testClearResetsBuffer() throws {
        var buffer = RingBuffer<String>(count: 4)
        try buffer.write("One")
        try buffer.write("Two")
        #expect(buffer.count == 2)
        #expect(!buffer.isEmpty)
        #expect(!buffer.isFull)

        buffer.clear()
        #expect(buffer.isEmpty)
        #expect(buffer.count == 0)
        #expect(buffer.first == nil)
        #expect(!buffer.isFull)
        #expect(buffer.description == "[]")

        // Ensure it can be used again after clearing
        try buffer.write("After Clear")
        #expect(buffer.count == 1)
        #expect(buffer.first == "After Clear")
    }
}
