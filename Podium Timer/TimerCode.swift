import SwiftUI
import Combine

class TimerCode: ObservableObject {
    @Published private var timer: Timer?
    @Published private var totalTime: TimeInterval = 60
    @Published var remainingTime: TimeInterval = 60
    @Published var timerRunning: Bool = false
    
    // Converts time progress for a percentage
    var timerProgress: CGFloat {
        guard totalTime > 0 else { return 1.0 }
        return 1.0 - (CGFloat(remainingTime) / CGFloat(totalTime))
    }
    
    // Converts remaining time to formatted string (Self-published)
    var timerAnalog: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second] // Format as minutes and seconds
        formatter.zeroFormattingBehavior = .pad    // Add leading zeros
        return formatter.string(from: remainingTime) ?? "00:00"
    }
    
    private var tickIncrement: TimeInterval = 0.01
    
    // Start timer
    func start(startTime: TimeInterval? = nil) {
        stop()
        timerRunning = true
        
        // If a start time is provided, set it. (Otherwise would carry on with current remaining time)
        if let startTime {
            totalTime = startTime
            remainingTime = startTime
        }
        
        // Schedules the timer to call tick every second
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
    }
    
    // Handle a timer tick
    private func tick() {
        if remainingTime > 0 {
            remainingTime -= tickIncrement
        } else {
            stop()
        }
    }
}
