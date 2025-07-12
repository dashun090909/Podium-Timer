import SwiftUI

struct DebateView: View {
    @EnvironmentObject var AppState: AppState

    // Overtime pulse state for background animation
    @State private var overtimePulse: Bool = true

    // State variable for swipe locking when timer is running
    @State private var swipeAllowed: Bool = true

    // Confirmation alert state
    @State private var showEndRoundConfirmation: Bool = false

    // Computed property for shared timers
    var timers: [TimerCode] {
        AppState.timers
    }

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
                Spacer()
                
                // Top bar with End Round and Save buttons
                HStack {
                    // End Round Button
                    Button(action: {
                        // Triggers end round confirmation
                        showEndRoundConfirmation = true
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
                    
                    // Save Button
                    Button(action: {
                        if AppState.timers.isEmpty {
                            AppState.timers = AppState.speechTimes.map { TimerCode(totalTime: $0 * 60) }
                        } // Add new timers to timer based on map of speech times on first appearance
                    }) {
                        Text("Save")
                            .font(.system(size:20, weight: .light))
                        .foregroundColor(.primary.opacity(0.7))
                    }
                    .offset(x: -40)
                }
                .padding(.horizontal)
                .offset(y: 72.5)
                
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
                .animation(.linear, value: timers.count)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(
                    swipeAllowed ? nil : Color.clear.contentShape(Rectangle())
                ) // Invisible overlay blocks swiping according to swipeAllowed
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
        // End round alert
        .alert(isPresented: $showEndRoundConfirmation) {
            Alert(
                title: Text("End Round?"),
                message: Text("Are you sure you want to return to the event selection screen?"),
                primaryButton: .destructive(Text("End Round")) {
                    AppState.timers = []
                    AppState.currentTabIndex = 0
                    withAnimation {
                        AppState.view = "EventsView"
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct DebateView_Previews: PreviewProvider {
    static var previews: some View {
        DebateView().environmentObject(AppState())
    }
}
