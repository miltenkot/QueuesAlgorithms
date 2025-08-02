//
//  DoubleStackQueue.swift
//  QueueApp
//

public class DoubleStackQueue<T>: Queue {
    
    private var leftStack: [T] = []
    private var rightStack: [T] = []
    private let capacity: Int?
    
    public init() {
        self.capacity = nil
    }
    
    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero.")
        self.capacity = capacity
    }
    
    // MARK: - Queue Protocol Conformance
    
    public var isEmpty: Bool {
        return leftStack.isEmpty && rightStack.isEmpty
    }
    
    public var peek: T? {
        !leftStack.isEmpty ? leftStack.last : rightStack.first
    }
    
    public var count: Int {
        leftStack.count + rightStack.count
    }
    
    public func enqueue(_ element: T) throws(QueueError) {
        if let maxCapacity = capacity, count >= maxCapacity {
            throw QueueError.capacityExceeded
        }
        rightStack.append(element)
    }
    
    public func dequeue() -> T? {
        if leftStack.isEmpty {
            leftStack = rightStack.reversed()
            rightStack.removeAll()
        }
        return leftStack.popLast()
    }
    
    public func clear() {
        leftStack.removeAll()
        rightStack.removeAll()
    }
}

extension DoubleStackQueue: CustomStringConvertible {
    public var description: String {
        let combined = leftStack.reversed() + rightStack
        return String(describing: combined)
    }
}
