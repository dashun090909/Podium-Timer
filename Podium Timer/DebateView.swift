import SwiftUI

struct DebateView: View {
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
        Text("Loaded DebateView with \(AppState.speechTitles.count) titles")
            .foregroundColor(.white)
        
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
                Spacer()
                
                // Top bar with End Round and Save buttons
                HStack {
                    // End Round Button
                    Button(action: {
                        // Reset all timers
                        timers = []
                        AppState.currentTabIndex = 0
                        AppState.view = "EventsView"
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                            Text("End Round")
                                .font(.system(size: 20, weight: .light))
                        }
                        .foregroundColor(.primary.opacity(0.7))
                    }
                    .offset(x: 30)

                    Spacer()

                    Button(action: {
                    }) {
                        Text("Save")
                            .font(.system(size:20, weight: .light))
                        .foregroundColor(.primary.opacity(0.7))
                    }
                    .offset(x: -40)
                }
                .padding(.horizontal)
                .offset(y: 65)
                
                // Stage Indicator
                StageIndicatorView(pageCount: AppState.speechTitles.count, currentPage: AppState.currentTabIndex, speechTypes: AppState.speechTypes)
                    .offset(y: 75)

                
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
                .overlay(
                    swipeAllowed ? nil : Color.clear.contentShape(Rectangle())
                ) // Invisible overlay blocks swiping according to swipeAllowed
                .onAppear {
                    if timers.isEmpty {
                        timers = AppState.speechTimes.map { TimerCode(totalTime: $0 * 60) }
                    } // Add new timers to timer based on map of speech times on first appearance
                    AppState.currentTabIndex = 0 // Force first indication for stage indicator
                }
                .padding(10)
                .offset(y:20)
                
                // Reset Button that interacts with current TimerCode instance
                Button(action: {
                    currentTimer.reset()
                    swipeAllowed = true
                }) {
                    Text("Reset")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color.primary)
                }
                .offset(y: -20)

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
                .padding(.bottom, 110)
                
            }
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DebateView()
        .environmentObject(AppState())
}
