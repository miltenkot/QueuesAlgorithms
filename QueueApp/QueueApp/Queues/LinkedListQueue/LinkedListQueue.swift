//
//  QueueLinkedList.swift
//  QueueApp
//


final class LinkedListQueue<T>: Queue {
    private var list = DoublyLinkedList<T>()
    private let capacity: Int?
    
    public init() {
        self.capacity = nil
    }
    
    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero.")
        self.capacity = capacity
    }
    
    // MARK: - Metody Protokołu Queue
    
    public func enqueue(_ element: T) throws(QueueError) {
        if let maxCapacity = capacity, list.count >= maxCapacity {
            throw QueueError.capacityExceeded
        }
        list.append(element)
    }
    
    public func dequeue() -> T? {
        return list.removeFirst()
    }
    
    public func clear() {
        list.clear()
    }
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    public var count: Int {
        return list.count
    }
    
    public var peek: T? {
        return list.first?.value
    }
}

extension LinkedListQueue: CustomStringConvertible {
    public var description: String {
        return String(describing: list)
    }
}


