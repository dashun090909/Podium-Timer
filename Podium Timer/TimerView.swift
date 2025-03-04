import SwiftUI

struct TimerView: View {
    @StateObject private var TimerCode: TimerCode

    let speechTitle: String   // Parameter for speechTitle text
    let totalTime: TimeInterval  // Parameter for total time
    @Binding var swipeAllowed: Bool // Parameter for parent view swipe control
    init(speechTitle: String, totalTime: TimeInterval, swipeAllowed: Binding<Bool>) {
        self.speechTitle = speechTitle
        self.totalTime = totalTime
        _swipeAllowed = swipeAllowed // Passes binding from parent
        _TimerCode = StateObject(wrappedValue: Podium_Timer.TimerCode(totalTime: totalTime)) // Creates own instance of TimerCode using totalTime
    }
    
    @State private var overtimePulse = true
    @State private var refreshTrigger = false // A toggle to force updates
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            // Overtime Background Pulse
            Rectangle()
                .frame(width: screenSize.width + 50, height: screenSize.height + 50)
                .foregroundStyle(TimerCode.overtime ? Color("OvertimeRed") : Color("BackgroundColor"))
                .opacity(overtimePulse ? 1 : 0)
                .animation(
                    TimerCode.overtime
                    ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                        : .default,
                    value: TimerCode.overtime
                )
            
            VStack {
                Spacer()
                
                // Title
                Text(speechTitle)
                    .font(.title.bold())
                    .padding(.top, 50)
                
                Spacer()
                
                // Timer circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color("RegressedColor"), lineWidth: 12)
                        .rotationEffect(Angle(degrees: -90))
                    
                    // Proggress bar
                    Circle()
                        .trim(from: TimerCode.timerProgress, to: 1)
                        .stroke(progressColor(), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .shadow(color: progressColor(), radius: 10)
                        .animation(.linear, value: TimerCode.timerProgress)
                    
                    // Overtime Indiciator
                    Text(TimerCode.overtime ? "OVERTIME" : "")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .kerning(3)
                        .offset(y: -50)
                        .animation(.easeIn, value: TimerCode.overtime)
                    
                    // Analog time
                    Text(TimerCode.timerAnalog)
                        .font(.system(size: 50, weight: .medium, design: .monospaced))
                        .kerning(3)
                }
                .frame(width: 300, height: 300)
                
                Spacer()
                
                // Start/Stop Button
                Button(action: {
                    if TimerCode.timerRunning {
                        TimerCode.stop()
                        swipeAllowed = true
                    } else {
                        TimerCode.start()
                        swipeAllowed = false // Locks swiping to prevent moving to other timers
                    }
                }) {
                    Text(TimerCode.timerRunning ? "Stop" : "Start")
                        .frame(width: 110, height: 110)
                        .background {
                            Circle()
                                .fill(Color(TimerCode.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.2))
                        }
                        .font(.system(size: 25, weight: .light))
                        .foregroundStyle(Color(TimerCode.timerRunning ? "DangerRed" : "StartingGreen"))
                        .animation(.linear(duration: 0.1), value: TimerCode.timerRunning)
                }
                .contentShape(Circle())
                .frame(width: 110, height: 110)
                .padding()
                
                // Reset button
                Button(action: {
                    TimerCode.reset()
                    swipeAllowed = true
                }) {
                    Text("Reset")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color.primary)
                }
                .padding(.bottom, 70)
                .padding()
                
            }
        }
        .frame(width: screenSize.width, height: screenSize.height)
        .background(Color("BackgroundColor").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
    
    // Determines color for progress bar
    private func progressColor() -> Color {
        // Color transition logic
        if TimerCode.remainingTime > 31 {
            return Color("StartingGreen")
        } else if TimerCode.remainingTime > 11 {
            return Color("WarningYellow")
        } else {
            return Color("DangerRed")
        }
    }
}

#Preview {
    TimerView(speechTitle: "AFF    |    1AC", totalTime: 360, swipeAllowed: .constant(true))
}
