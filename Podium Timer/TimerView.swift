import SwiftUI

struct TimerView: View {
    @EnvironmentObject var AppState: AppState

    @ObservedObject var TimerCode: TimerCode

    @AppStorage("theme") private var theme: String = "Dark"
    @AppStorage("affColorHex") private var affColorHex: String = "#0D6FDE"
    @AppStorage("negColorHex") private var negColorHex: String = "#C42329"
    @AppStorage("speakerIdentifierEnabled") private var speakerIdentifierEnabled: Bool = true

    let speechTitle: String   // Parameter for speech title text
    let totalTime: TimeInterval  // Parameter for total time
    
    init(speechTitle: String, totalTime: TimeInterval, timerCode: TimerCode) {
        self.speechTitle = speechTitle
        self.totalTime = totalTime
        self.TimerCode = timerCode
    }
    
    @State private var refreshTrigger = false // A toggle to force updates
    
    var body: some View {
        ZStack {
            VStack {
                // Title
                ZStack {
                    // Background for AFF/NEG
                    ZStack {
                        // Base rectangle
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                (
                                    AppState.speechTypes[AppState.currentTabIndex] == "AFF" ? Color(hex: affColorHex) :
                                    AppState.speechTypes[AppState.currentTabIndex] == "NEG" ? Color(hex: negColorHex) :
                                    AppState.speechTypes[AppState.currentTabIndex] == "AFFCX" ? Color(hex: affColorHex) :
                                    AppState.speechTypes[AppState.currentTabIndex] == "NEGCX" ? Color(hex: negColorHex) :
                                    (theme == "Light" ? Color.primary.opacity(0.6) : Color.primary)
                                ).opacity(0.4)
                            )

                        // Stripes for CX speeches only
                        if AppState.speechTypes[AppState.currentTabIndex].contains("CX") {
                            ZStack {
                                ForEach(0..<50, id: \.self) { i in
                                    Rectangle()
                                        .fill(Color("BackgroundColor"))
                                        .frame(width: 15, height: 140)
                                        .rotationEffect(.degrees(45))
                                        .offset(x: CGFloat(i) * 60 - 450)
                                }
                            }
                            .frame(width: min(CGFloat(speechTitle.count) * 60, 300), height: 70)
                        }
                    }
                    .frame(width: min(CGFloat(speechTitle.count) * 60, 300), height: 70)                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    // Title text
                    Text(speechTitle)
                        .font(.title.bold())
                }
                .padding(.bottom, 10)
                                
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
                        .animation((TimerCode.timerRunning || TimerCode.resetPeriod) ? .linear : nil, value: TimerCode.timerProgress)
                    
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
                    
                    // Speaker Indicator if relevant for this event
                    if AppState.speechSpeakers.count != 0 {
                        Text(AppState.speechSpeakers[AppState.currentTabIndex])
                            .font(.system(size: 17.5, weight: .medium, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary.opacity((TimerCode.timerRunning ? 0.2 : 0.75) * (speakerIdentifierEnabled ? 1 : 0)))
                            .offset(y: 60)
                            .animation(.easeIn, value: TimerCode.timerRunning)
                    }
                }
                .frame(width: 290, height: 300)
                .padding(20)
            }
        }
    }
    
    @AppStorage("warningThreshold") private var warningThreshold: Int = 60
    @AppStorage("dangerThreshold") private var dangerThreshold: Int = 30

    // Determines color for progress bar
    private func progressColor() -> Color {
        if TimerCode.remainingTime > TimeInterval(warningThreshold + 1) {
            return Color("StartingGreen")
        } else if TimerCode.remainingTime > TimeInterval(dangerThreshold + 1) {
            return Color("WarningYellow")
        } else {
            return Color("DangerRed")
        }
    }
}

#Preview {
    TimerView(
        speechTitle: "1AC",
        totalTime: 360,
        timerCode: TimerCode(totalTime: 360)
    )
    .environmentObject(AppState())
}
