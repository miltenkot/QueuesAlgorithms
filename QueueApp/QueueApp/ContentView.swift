import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var times: [QueueType: TimeInterval] = [:]
    @State private var progress: [QueueType: Double] = [:]
    @State private var isRunning = false
    @State private var countdown: Int = 0
    @State private var showResults = false
    
    private let totalDistance: CGFloat = 300
    private let itemCount = 100_000
    private let minAnimationDuration: TimeInterval = 2.0
    private let maxAnimationDuration: TimeInterval = 8.0
    private let countdownDuration: Int = 5
    
    var displayText: String {
        if countdown > 0 {
            return "Starting in \(countdown)..."
        } else if isRunning {
            return "Go!"
        } else {
            return ""
        }
    }
    
    var displayColor: Color {
        if countdown > 0 {
            return .gray
        } else if isRunning {
            return .green
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🏁 Queue Race 🐌")
                .font(.largeTitle)
            
            Text(displayText)
                .font(.title2)
                .foregroundColor(displayColor)
                .frame(height: 50)
            
            ForEach(QueueType.allCases) { type in
                HStack {
                    Text(type.snailEmoji)
                        .font(.largeTitle)
                        .offset(x: CGFloat(progress[type] ?? 0) * totalDistance)
                        .animation(.easeOut(duration: normalizedAnimationDuration(for: type)), value: progress[type])
                    
                    Spacer()
                }
                .frame(height: 40)
                .padding(.horizontal)
            }
            
            Button(isRunning ? "Running..." : "Start Race") {
                Task {
                    await startRace()
                }
            }
            .disabled(isRunning)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .geometryGroup()
            
            if showResults {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏆 Results")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    let sortedQueues = QueueType.allCases.sorted { (times[$0] ?? .infinity) < (times[$1] ?? .infinity) }
                    
                    ForEach(Array(sortedQueues.enumerated()), id: \.element) { index, type in
                        HStack {
                            Text(medalEmoji(for: index) + " " + type.rawValue)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(times[type]!.formatted(.number.precision(.fractionLength(3))))s")
                                .frame(alignment: .trailing)
                        }
                    }
                }
                .padding(.top, 12)
            }
            
        }
        .padding()
        .onAppear {
            resetPositions()
        }
        .animation(.default, value: showResults)
    }
    
    func medalEmoji(for position: Int) -> String {
        switch position {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return ""
        }
    }
    
    func resetPositions() {
        times = [:]
        for type in QueueType.allCases {
            progress[type] = 0.0
        }
        countdown = 0
    }
    
    private func normalizedAnimationDuration(for type: QueueType) -> TimeInterval {
        guard let minTime = times.values.min(), let maxTime = times.values.max(), let currentTime = times[type] else {
            return 1.0
        }
        
        if minTime == maxTime {
            return (minAnimationDuration + maxAnimationDuration) / 2
        }
        
        let normalizedValue = (currentTime - minTime) / (maxTime - minTime)
        return minAnimationDuration + (normalizedValue * (maxAnimationDuration - minAnimationDuration))
    }
    
    func startRace() async {
        isRunning = true
        showResults = false
        resetPositions()
        
        async let countdownDone: Void = performCountdown()
        async let benchmarkResults: [QueueType: TimeInterval] = performBenchmark()
        
        let results = await benchmarkResults
        await countdownDone
        
        self.times = results
        try? await Task.sleep(for: .seconds(0.1))
        
        for type in QueueType.allCases {
            progress[type] = 1.0
        }
        
        try? await Task.sleep(for: .seconds(maxAnimationDuration + 0.5))
        
        showResults = true
        isRunning = false
    }
    
    func performCountdown() async {
        for i in (1...countdownDuration).reversed() {
            countdown = i
            try? await Task.sleep(for: .seconds(1))
        }
        countdown = 0
    }
    
    func performBenchmark() async -> [QueueType: TimeInterval] {
        var newTimes: [QueueType: TimeInterval] = [:]
        await withTaskGroup(of: (QueueType, TimeInterval).self) { group in
            for type in QueueType.allCases {
                group.addTask {
                    let time = await QueueRunner.benchmark(type, count: itemCount)
                    return (type, time)
                }
            }
            for await (type, time) in group {
                newTimes[type] = time
            }
        }
        return newTimes
    }
}



import Foundation
import SwiftUI // Potrzebne dla Color

enum QueueType: String, CaseIterable, Identifiable {
    case array = "ArrayQueue"
    case linkedList = "LinkedListQueue"
    case ringBuffer = "RingBufferQueue"
    case doubleStack = "DoubleStackQueue"
    
    var id: String { rawValue }
    
    var snailEmoji: String {
        switch self {
        case .array: return "🐌"
        case .linkedList: return "🐞"
        case .ringBuffer: return "🦎"
        case .doubleStack: return "🦕"
        }
    }
}

struct QueueRunner {
    static func benchmark(_ type: QueueType, count: Int) async -> TimeInterval {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let start = DispatchTime.now()
                
                switch type {
                case .array:
                    var q = ArrayQueue<String>()
                    for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
                    for _ in 0..<count { _ = q.dequeue() }
                case .linkedList:
                    let q = LinkedListQueue<String>()
                    for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
                    for _ in 0..<count { _ = q.dequeue() }
                case .ringBuffer:
                    let q = RingBufferQueue<String>(count: count)
                    for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
                    for _ in 0..<count { _ = q.dequeue() }
                case .doubleStack:
                    let q = DoubleStackQueue<String>()
                    for i in 0..<count { _ = try! q.enqueue("Item \(i)") }
                    for _ in 0..<count { _ = q.dequeue() }
                }
                
                let end = DispatchTime.now()
                let duration = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
                continuation.resume(returning: duration)
            }
        }
    }
}

#Preview {
    ContentView()
}
