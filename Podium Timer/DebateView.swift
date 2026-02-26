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

    // New state variables for sheet presentation
    @State private var showAffPrep: Bool = false
    @State private var showNegPrep: Bool = false

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
    
    private func formatMMSS(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
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
                
                // Top bar with End Round button
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
                .offset(y: AppState.eventPrepTime > 0 ? -65 : -30)
                

                
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
                .padding(.bottom, AppState.eventPrepTime > 0 ? 90 : 110)
            }
            
            // Prep time buttons
            HStack {
                
                // AFF Prep Time
                Button(action: {
                    if AppState.eventPrepTime > 0 {
                        showAffPrep = true
                    }
                }, label: {
                    Text("Prep\n\(formatMMSS(AppState.prepTimeAFF))")
                        .font(.system(size: 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: affColorHex))
                        .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                        .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))
                        .animation(.default, value: currentTimer.timerRunning)
                })
                
                Spacer()
                
                // NEG Prep Time
                Button(action: {
                    if AppState.eventPrepTime > 0 {
                        showNegPrep = true
                    }                }, label: {
                    Text("Prep\n\(formatMMSS(AppState.prepTimeNEG))")
                        .font(.system(size: 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: negColorHex))
                        .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                        .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))
                        .animation(.default, value: currentTimer.timerRunning)
                })
            }
            .padding(75)
            .offset(y: 210)
        }
        
        // Overtime pulser
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                if currentTimer.overtime && overtimeFlashEnabled {
                    overtimePulse.toggle()
                } else {
                    overtimePulse = true
                }
            }
        }
        .background(Color("BackgroundColor")).ignoresSafeArea()
        
        // End round alert
        .alert(isPresented: $showEndRoundConfirmation) {
            Alert(
                title: Text("End Round?"),
                message: Text("Are you sure you want to return to the event selection screen?"),
                primaryButton: .destructive(Text("End Round")) {
                    AppState.prepTimeAFF = Int(AppState.eventPrepTime * 60)
                    AppState.prepTimeNEG = Int(AppState.eventPrepTime * 60)
                    AppState.timers = []
                    AppState.currentTabIndex = 0
                    withAnimation {
                        AppState.view = "EventsView"
                    }
                },
                secondaryButton: .cancel()
            )
        }
        
        // Prep Time Overlay Sheets
        .sheet(isPresented: $showAffPrep) {
            PrepTimeView(side: .aff, color: Color(hex: affColorHex), affRemainingSeconds: $AppState.prepTimeAFF, negRemainingSeconds: $AppState.prepTimeNEG, isPresented: $showAffPrep)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNegPrep) {
            PrepTimeView(side: .neg, color: Color(hex: negColorHex), affRemainingSeconds: $AppState.prepTimeAFF, negRemainingSeconds: $AppState.prepTimeNEG, isPresented: $showNegPrep)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
        DebateView()
            .environmentObject(AppState())
}
