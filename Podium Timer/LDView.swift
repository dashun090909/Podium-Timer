import SwiftUI

struct LDView: View {
    @EnvironmentObject var appState: AppState
        
    // Individual TimerCode instances for each timer
    @StateObject private var timer1 = TimerCode(totalTime: 360)
    @StateObject private var timer2 = TimerCode(totalTime: 180)
    @StateObject private var timer3 = TimerCode(totalTime: 420)
    @StateObject private var timer4 = TimerCode(totalTime: 180)
    
    // Overtime pulse state for background animation
    @State private var overtimePulse: Bool = true
    
    @State private var swipeAllowed: Bool = true
    
    // Dynamic variable that switches TimerCode instance depending on current tab
    var currentTimer: TimerCode {
        switch appState.currentTabIndex {
        case 1: return timer1
        case 2: return timer2
        case 3: return timer3
        case 4: return timer4
        default: return timer1
        }
    }

    var body: some View {
        ZStack {
            // Overtime background pulse
            Rectangle()
                .frame(width: UIScreen.main.bounds.width + 50, height: UIScreen.main.bounds.height + 50)
                .foregroundStyle(Color(currentTimer.overtime ? "OvertimeRed" : "BackgroundColor"))
                .animation(.easeInOut(duration: 0.3), value: currentTimer.overtime)
                .opacity(currentTimer.overtime ? (overtimePulse ? 1 : 0) : 0)
                .animation(.easeInOut(duration: 0.5), value: overtimePulse)
                .onAppear() {Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    if currentTimer.overtime {
                        overtimePulse.toggle()
                    } else {
                        overtimePulse = true
                    }
                }} // Animation timer to manipulate overtimePulse
            
            VStack {
                // Stage Indicator
                StageIndicatorView(pageCount: 4, currentPage: appState.currentTabIndex)
                    .padding(100)
                
                // Tabview of TimerView instances
                TabView(selection: $appState.currentTabIndex) {
                    TimerView(speechTitle: "AFF | 1AC", totalTime: 360, prepTime: false, timerCode: timer1)
                        .tag(1)
                    TimerView(speechTitle: "AFF | CX", totalTime: 180, prepTime: false, timerCode: timer2)
                        .tag(2)
                    TimerView(speechTitle: "NEG | 1NC", totalTime: 420, prepTime: false, timerCode: timer3)
                        .tag(3)
                    TimerView(speechTitle: "NEG | CX", totalTime: 180, prepTime: false, timerCode: timer4)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.top, -120)
                .overlay(
                    swipeAllowed ? nil : Color.clear.contentShape(Rectangle())
                ) // Invisible overlay blocks swiping according to swipeAllowed
                .onAppear {
                    appState.currentTabIndex = 1 // Force first indication for stage indicator
                }
                
                // Reset Button that interacts with current TimerCode instance
                Button(action: {
                    currentTimer.reset()
                    swipeAllowed = true
                }) {
                    Text("Reset")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color.primary)
                }
                .padding(.top, -40)

                // Start/Stop button that interacts with current TimerCode instance
                Button(action: {
                    if currentTimer.timerRunning {
                        currentTimer.stop()
                        swipeAllowed = true
                    } else {
                        currentTimer.start()
                        swipeAllowed = false
                    }
                }) {
                    Text(currentTimer.timerRunning ? "Stop" : "Start")
                        .frame(width: 110, height: 110)
                        .background {
                            Circle()
                                .fill(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.2))
                        }
                        .font(.system(size: 25, weight: .light))
                        .foregroundStyle(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen"))
                }
                .contentShape(Circle())
                .padding(.bottom, 100)
                
                Spacer()
            }
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LDView()
        .environmentObject(AppState())
}
