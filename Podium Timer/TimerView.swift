import SwiftUI

struct TimerView: View {
    @EnvironmentObject var appState: AppState

    @ObservedObject var TimerCode: TimerCode

    let speechTitle: String   // Parameter for speechTitle text
    let totalTime: TimeInterval  // Parameter for total time
    let prepTime: Bool // Parameter for if timer is prep time
    init(speechTitle: String, totalTime: TimeInterval, prepTime: Bool, timerCode: TimerCode) {
        self.speechTitle = speechTitle
        self.totalTime = totalTime
        self.prepTime = prepTime
        self.TimerCode = timerCode
    }
    
    @State private var refreshTrigger = false // A toggle to force updates
    
    var body: some View {
        ZStack {
            VStack {
                // Title
                Text(speechTitle)
                    .font(.title.bold())
                    .padding(20)
                                
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
                .padding(20)
            }
        }
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
    TimerView(
        speechTitle: "AFF    |    1AC",
        totalTime: 360,
        prepTime: false,
        timerCode: TimerCode(totalTime: 360)
    )
    .environmentObject(AppState())
}
