//
//  Queue.swift
//  QueueApp
//

import Foundation

public protocol Queue: Sendable {
    associatedtype Element
    mutating func enqueue(_ element: Element) throws(QueueError)
    mutating func dequeue() -> Element?
    mutating func clear() // Dodano
    var isEmpty: Bool { get }
    var peek: Element? { get }
    var count: Int { get }
}

public nonisolated enum QueueError: Error{
    case capacityExceeded
}
