import SwiftUI

struct LDView: View {
    @EnvironmentObject var AppState: AppState
    
    // Array of TimerCode instances for each timer
    @State private var timers: [TimerCode] = []
    
    // Overtime pulse state for background animation
    @State private var overtimePulse: Bool = true
    
    // State variable for swipe locking when timer is running
    @State private var swipeAllowed: Bool = true
    
    // Finds current timer according to current tab index
    var currentTimer: TimerCode {
        guard AppState.currentTabIndex < timers.count else {
            return TimerCode(totalTime: 0)
        }
        return timers[AppState.currentTabIndex]
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
                }} // Animation timer to manipulate overtime pulse
            
            VStack {
                // Stage Indicator
                StageIndicatorView(pageCount: AppState.speechTitles.count, currentPage: AppState.currentTabIndex, speechTypes: AppState.speechTypes)
                    .padding(100)
                
                // Tabview of TimerView instances according to AppState arrays
                TabView(selection: $AppState.currentTabIndex) {
                    ForEach(0..<AppState.speechTitles.count, id: \.self) { index in
                        TimerView(
                            speechTitle: AppState.speechTitles[index],
                            totalTime: AppState.speechTimes[index],
                            timerCode: currentTimer
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.top, -180)
                .overlay(
                    swipeAllowed ? nil : Color.clear.contentShape(Rectangle())
                ) // Invisible overlay blocks swiping according to swipeAllowed
                .onAppear {
                    if timers.isEmpty {
                        timers = AppState.speechTimes.map { TimerCode(totalTime: $0) }
                    }
                    AppState.currentTabIndex = 0 // Force first indication for stage indicator
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
                .padding(.top, -50)

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
