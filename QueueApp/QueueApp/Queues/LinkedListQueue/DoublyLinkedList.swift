//
//  DoublyLinkedList.swift
//  QueueApp
//

final class DoublyLinkedList<T> {
    
    private var head: Node<T>?
    private var tail: Node<T>?
    private(set) var count: Int = 0
    
    init() { }
    
    var isEmpty: Bool {
        head == nil
    }
    
    var first: Node<T>? {
        head
    }
    
    var last: Node<T>? {
        tail
    }
    
    public func append(_ value: T) {
        let newNode = Node(value: value)
        
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
        count += 1
    }
    
    func prepend(_ value: T) {
        let newNode = Node(value: value)
        if let headNode = head {
            newNode.next = headNode
            headNode.previous = newNode
        } else {
            tail = newNode
        }
        head = newNode
        count += 1
    }
    
    func node(at index: Int) -> Node<T>? {
        guard index >= 0 && index < count else { return nil }
        
        var currentNode = head
        for _ in 0..<index {
            currentNode = currentNode?.next
        }
        return currentNode
    }
    
    func insert(_ value: T, at index: Int) {
        guard index >= 0 else {
            append(value)
            return
        }
        guard index < count else {
            append(value)
            return
        }
        
        if index == 0 {
            prepend(value)
            return
        }
        
        let newNode = Node(value: value)
        let currentNode = node(at: index)
        let prevNode = currentNode?.previous
        
        newNode.previous = prevNode
        newNode.next = currentNode
        prevNode?.next = newNode
        currentNode?.previous = newNode
        
        count += 1
    }
    
    @discardableResult
    func remove(_ node: Node<T>) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else { // Usuwamy head
            head = next
        }
        
        if let next = next {
            next.previous = prev
        } else {
            tail = prev
        }
        
        if head == nil && tail == nil {
            count = 0
        } else {
            count -= 1
        }
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    func remove(at index: Int) -> T? {
        guard let nodeToRemove = node(at: index) else { return nil }
        return remove(nodeToRemove)
    }
    
    func removeFirst() -> T? {
        guard let headNode = head else { return nil }
        return remove(headNode)
    }
    
    func removeLast() -> T? {
        guard let tailNode = tail else { return nil }
        return remove(tailNode)
    }
    
    func clear() {
        head = nil
        tail = nil
        count = 0
    }
}

extension DoublyLinkedList: CustomStringConvertible {
    var description: String {
        guard let head = head else { return "Empty List" }
        var nodes: [String] = []
        var current: Node<T>? = head
        while let node = current {
            nodes.append(String(describing: node.value))
            current = node.next
        }
        return nodes.joined(separator: " <-> ")
    }
}
