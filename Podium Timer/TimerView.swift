import SwiftUI

struct TimerView: View {
    @EnvironmentObject var TimerCode: TimerCode
    
    var body: some View {
        VStack {
            Spacer()
            
            // Title
            Text("AFF    |    1AC")
                .font(.title.bold())
                .padding()
            
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
                    .animation(.linear(duration: 0.1), value:  TimerCode.timerProgress)

                // Analog time
                Text(TimerCode.timerAnalog)
                    .font(.system(size: 50, weight: .medium, design: .monospaced))
                    .kerning(3)
            }
            .frame(width: 300, height: 300)
            .padding()
            
            Spacer()
            
            // Start/Stop Button
            Button(action: {
                if TimerCode.timerRunning { TimerCode.stop() }
                else { TimerCode.start() }
            }) {
                Text(TimerCode.timerRunning ? "Stop" : "Start")
                    .frame(width: 110, height: 110)
                    .background {
                        Circle()
                            .fill(Color(TimerCode.timerRunning ? "OvertimeRed" : "StartingGreen").opacity(0.2))
                    }
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(Color(TimerCode.timerRunning ? "OvertimeRed" : "StartingGreen"))
                    .animation(.linear(duration: 0.1), value: TimerCode.timerRunning)
            }
            .contentShape(Circle())
            .frame(width: 110, height: 110)
            
            // Reset button
            Button(action: {
                TimerCode.reset()
            }) {
                Text("Reset")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Color.primary)
            }
            .padding()
        }
        .frame(width: 300, height: 700)
        .padding(1000)
        .background(Color("BackgroundColor"))
        .preferredColorScheme(.dark)
    }
    
    // Determines color for progress bar
    private func progressColor() -> Color {
        // Color transition logic
        if TimerCode.remainingTime > 30 {
            return Color("StartingGreen")
        } else if TimerCode.remainingTime > 10 {
            return Color("WarningYellow")
        } else {
            return Color("OvertimeRed")
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerCode())
}
