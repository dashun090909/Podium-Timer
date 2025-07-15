import SwiftUI

struct DebateView: View {
    @EnvironmentObject var AppState: AppState
    @AppStorage("theme") private var theme: String = "Dark"
    @AppStorage("overtimeFlashEnabled") private var overtimeFlashEnabled: Bool = true
    @AppStorage("timerStageDimmingEnabled") private var timerStageDimmingEnabled: Bool = true
    @AppStorage("affColorHex") private var affColorHex: String = "#0D6FDE"
    @AppStorage("negColorHex") private var negColorHex: String = "#C42329"
    @AppStorage("prepTimeAFF") private var prepTimeAFF: Int = 240
    @AppStorage("prepTimeNEG") private var prepTimeNEG: Int = 240
    
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
                .opacity(
                    currentTimer.overtime && overtimeFlashEnabled
                    ? (overtimePulse ? 1 : 0)
                    : 0
                )
                .animation(.easeInOut(duration: 0.5), value: overtimePulse)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        if currentTimer.overtime && overtimeFlashEnabled {
                            overtimePulse.toggle()
                        } else {
                            overtimePulse = true
                        }
                    }
                }

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
                        .foregroundColor(.primary.opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8))
                    }
                    .offset(x: 30)
                    .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                    .animation(.default, value: currentTimer.timerRunning)

                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        if AppState.timers.isEmpty {
                            AppState.timers = AppState.speechTimes.map { TimerCode(totalTime: $0 * 60) }
                        } // Add new timers to timer based on map of speech times on first appearance
                    }) {
                        Text("Save")
                            .font(.system(size:20, weight: .light))
                        .foregroundColor(.primary.opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.7))
                    }
                    .offset(x: -40)
                    .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                    .animation(.default, value: currentTimer.timerRunning)
                }
                .padding(.horizontal)
                .offset(y: 72.5)
                
                // Stage Indicator
                StageIndicatorView(pageCount: AppState.speechTitles.count, currentPage: AppState.currentTabIndex, speechTypes: AppState.speechTypes)
                    .environmentObject(currentTimer)
                    .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.05 : 1.0)
                    .animation(.easeInOut, value: currentTimer.timerRunning)
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
                
                // Reset Button that interacts with current TimerCode instance
                Button(action: {
                    if !currentTimer.timerRunning {
                        currentTimer.reset()
                        swipeAllowed = true
                    }
                }) {
                    Text("Reset")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color.primary)
                        .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8)
                }
                .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                .offset(y: -65)
                

                
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
                                .fill(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.1))
                        }
                        .font(.system(size: 25, weight: .light))
                        .foregroundStyle(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen"))
                }
                .contentShape(Circle())
                .padding(.bottom, 90)
            }
            
            // Prep time buttons
            HStack {
                Button(action: {
                    // AFF prep time button action
                }) {
                    Text("Prep\n4:00")
                        .font(.system(size: 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: affColorHex))
                        .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8)
                        .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                        .animation(.default, value: currentTimer.timerRunning)
                }
                
                Spacer()
                
                Button(action: {
                    // NEG prep time button action
                }) {
                    Text("Prep\n4:00")
                        .font(.system(size: 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: negColorHex))
                        .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8)
                        .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                        .animation(.default, value: currentTimer.timerRunning)
                }
            }
            .padding(75)
            .offset(y: 210)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                if currentTimer.overtime && overtimeFlashEnabled {
                    overtimePulse.toggle()
                } else {
                    overtimePulse = true
                }
            }
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
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

#Preview {
        DebateView()
            .environmentObject(AppState())
}
