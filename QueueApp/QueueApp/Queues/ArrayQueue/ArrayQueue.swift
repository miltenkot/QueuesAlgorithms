//
//  ArrayQueue.swift
//  QueueApp
//

public struct ArrayQueue<T>: Queue {
    private var array: [T] = []
    private let capacity: Int?
    
    public init() {
        self.capacity = nil
    }
    
    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero.")
        self.capacity = capacity
    }
    
    // MARK: - Queue Protocol Methods
    
    public mutating func enqueue(_ element: T) throws(QueueError) {
        if let maxCapacity = capacity, array.count >= maxCapacity {
            throw QueueError.capacityExceeded
        }
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        isEmpty ? nil : array.removeFirst()
    }
    
    public mutating func clear() {
        array.removeAll()
    }
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public var count: Int {
        array.count
    }
    
    public var peek: T? {
        array.first
    }
}

// MARK: - Rozszerzenie dla CustomStringConvertible

extension ArrayQueue: CustomStringConvertible {
    public var description: String {
        String(describing: array)
    }
}
