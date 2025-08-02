//
//  RingBuffer.swift
//  QueueApp
//

// MARK: - RingBufferError for RingBuffer specific errors

public nonisolated enum RingBufferError: Error {
    case bufferFull
    case bufferEmpty
}

// MARK: - Enhanced RingBuffer Struct

public struct RingBuffer<T> {
    
    private var array: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    
    public init(count: Int) {
        precondition(count > 0, "Ring buffer capacity must be greater than zero.")
        array = Array<T?>(repeating: nil, count: count)
    }
    
    public var first: T? {
        isEmpty ? nil : array[readIndex % array.count]
    }
    
    public mutating func write(_ element: T) throws(RingBufferError) {
        guard !isFull else {
            throw RingBufferError.bufferFull
        }
        array[writeIndex % array.count] = element
        writeIndex += 1
    }
    
    public mutating func read() -> T? {
        guard !isEmpty else {
            return nil
        }
        let element = array[readIndex % array.count]
        readIndex += 1
        return element
    }
    
    public mutating func clear() {
        readIndex = 0
        writeIndex = 0
        array = Array<T?>(repeating: nil, count: array.count)
    }
    
    public var count: Int {
        return availableSpaceForReading
    }
    
    private var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    private var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }
}

extension RingBuffer: CustomStringConvertible {
    public var description: String {
        let values = (0..<availableSpaceForReading).compactMap {
            array[($0 + readIndex) % array.count]
        }.map { String(describing: $0) }
        return "[" + values.joined(separator: ", ") + "]"
    }
}
