import SwiftUI
import Combine

class TimerCode: ObservableObject {
    @Published var remainingTime: TimeInterval = 60
    @Published var timerRunning: Bool = false
    @Published var overtime: Bool = false
    @Published var resetPeriod: Bool = false
    
    private var timer: Timer?
    private var totalTime: TimeInterval = 60
    private var startTime: Date?
    private var startingRemainingTime: TimeInterval = 60
    
    init(totalTime: TimeInterval) {
            self.totalTime = totalTime
            self.remainingTime = totalTime
        }
    
    private var tickIncrement: TimeInterval = 0.01
    
    private var timerSpeed: Double = 1
    
    // Converts time progress for a percentage for visual indicator
    var timerProgress: CGFloat {
        guard totalTime > 0 else { return 1.0 }
        let adjustedRemaining = max(0, remainingTime) // If remaining time < 0, treat as 0
        return 1.0 - (CGFloat(adjustedRemaining) / CGFloat(totalTime))
    }
    
    // Converts remaining time to formatted string (Self-published)
    var timerAnalog: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second] // Format as minutes and seconds
        formatter.zeroFormattingBehavior = .pad    // Add leading zeros
        return formatter.string(from: abs(remainingTime)) ?? "00:00"
    }
    
    
    // Start timer
    func start(startTime: TimeInterval? = nil) {
        stop()
        self.startTime = Date()
        timerRunning = true
        
        // If a start time is provided, set it. (Otherwise would carry on with current remaining time)
        if let startTime {
            totalTime = startTime
            remainingTime = startTime
            startingRemainingTime = startTime
        }
        
        startingRemainingTime = remainingTime
        
        // Schedules the timer to call tick every tick increment
        timer = Timer.scheduledTimer(withTimeInterval: tickIncrement, repeats: true) { [weak self] _ in self?.tick() }
    }
    
    // Stop the timer
    func stop() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
    }
        
    // Reset the timer
    func reset() {
        stop()
        remainingTime = totalTime
        startingRemainingTime = totalTime
        startTime = nil
        overtime = false
        
        // Set reset period to true for a half second
        resetPeriod = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetPeriod = false
        }
    }
    
    // Handle a timer tick
    private func tick() {
        DispatchQueue.main.async {
            guard self.timerRunning, let startedAt = self.startTime else { return }

            // Compute remaining time based on the current clock time relative to when we started.
            let elapsed = Date().timeIntervalSince(startedAt) * self.timerSpeed
            let newRemaining = self.startingRemainingTime - elapsed

            withAnimation(.linear(duration: 0.05)) {
                self.remainingTime = newRemaining
                self.overtime = newRemaining < 0.5
            }
        }
    }
}
