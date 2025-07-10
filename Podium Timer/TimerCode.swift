import SwiftUI
import Combine

class TimerCode: ObservableObject {
    @Published var remainingTime: TimeInterval = 60
    @Published var timerRunning: Bool = false
    @Published var overtime: Bool = false
    
    private var timer: Timer?
    private var totalTime: TimeInterval = 60
    private var startTime: Date?
    
    init(totalTime: TimeInterval) {
            self.totalTime = totalTime
            self.remainingTime = totalTime
        }
    
    private var tickIncrement: TimeInterval = 0.01
    
    private var timerSpeed: Double = 5
    
    // Converts time progress for a percentage
    var timerProgress: CGFloat {
        guard totalTime > 0 else { return 1.0 }
        let adjustedRemaining = max(0, remainingTime) // If remainingTime < 0, treat as 0
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
        self.startTime = Date.now
        timerRunning = true
        
        // If a start time is provided, set it. (Otherwise would carry on with current remaining time)
        if let startTime {
            totalTime = startTime
            remainingTime = startTime
        }
        
        // Schedules the timer to call tick every tickIncrement second
        timer = Timer.scheduledTimer(withTimeInterval: tickIncrement, repeats: true) { [weak self] _ in self?.tick() }
    }
    
    // Stop the timer
    func stop() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
        overtime = false
    }
        
    // Reset the timer
    func reset() {
        stop()
        remainingTime = totalTime
        overtime = false
    }
    
    // Handle a timer tick
    private func tick() {
        DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.05)) { // Force animation recognition
                    self.remainingTime -= self.tickIncrement * self.timerSpeed
                    if self.remainingTime < 0.5 {
                        self.overtime = true
                    } else {
                        self.overtime = false
                    }
                }
            }
    }
}
