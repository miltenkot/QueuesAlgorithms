//
//  RingBufferQueue.swift
//  QueueApp
//

// MARK: - Enhanced RingBufferQueue Class

public class RingBufferQueue<T>: Queue {
    
    private var ringBuffer: RingBuffer<T>
    
    public init(count: Int) {
        ringBuffer = RingBuffer<T>(count: count)
    }
    
    // MARK: - Queue Protocol Conformance
    
    public var isEmpty: Bool {
        return ringBuffer.isEmpty
    }
    
    public var peek: T? {
        return ringBuffer.first
    }
    
    public var count: Int {
        return ringBuffer.count
    }
    
    public func enqueue(_ element: T) throws(QueueError) {
        do {
            try ringBuffer.write(element)
        } catch RingBufferError.bufferFull {
            throw QueueError.capacityExceeded
        } catch {
            fatalError("Unexpected error from RingBuffer.write: \(error)")
        }
    }
    
    public func dequeue() -> T? {
        return ringBuffer.read()
    }
    
    public func clear() {
        ringBuffer.clear()
    }
}

extension RingBufferQueue: CustomStringConvertible {
    public var description: String {
        String(describing: ringBuffer)
    }
}
