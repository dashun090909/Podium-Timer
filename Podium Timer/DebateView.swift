import SwiftUI

// Overtime red background that enables when timer enters overtime
private struct OvertimeBackground: View {
    @ObservedObject var timerCode: TimerCode
    let overtimeRedEnabled: Bool

    var body: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.width + 50, height: UIScreen.main.bounds.height + 50)
            .foregroundStyle(Color(timerCode.overtime ? "OvertimeRed" : "BackgroundColor"))
            .opacity(timerCode.overtime && overtimeRedEnabled && timerCode.timerRunning ? 1 : 0)
            .animation(
                .easeInOut(duration: 0.5),
                value: timerCode.overtime && timerCode.timerRunning
            )
    }
}

struct DebateView: View {
    @EnvironmentObject var AppState: AppState
    @AppStorage("theme") private var theme: String = "Dark"
    @AppStorage("overtimeRedEnabled") private var overtimeRedEnabled: Bool = true
    @AppStorage("timerStageDimmingEnabled") private var timerStageDimmingEnabled: Bool = true
    @AppStorage("affColorHex") private var affColorHex: String = "#0D6FDE"
    @AppStorage("negColorHex") private var negColorHex: String = "#C42329"
    @AppStorage("prepTimeAFF") private var prepTimeAFF: Int = 240
    @AppStorage("prepTimeNEG") private var prepTimeNEG: Int = 240

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
    
    // Handles custom iPad layout trigger
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Seconds to digital time formatter
    private func formatMMSS(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let secs = clamped % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    var body: some View {
        ZStack {
            // Overtime background
            OvertimeBackground(
                timerCode: currentTimer,
                overtimeRedEnabled: overtimeRedEnabled
            )

            VStack {
                if !isPad {
                    Spacer()
                    Spacer()

                }
                
                // Top bar with End Round button
                HStack {
                    // End Round Button
                    Button(action: {
                        // Triggers end round confirmation
                        showEndRoundConfirmation = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .bold))
                            Text("End Round")
                                .font(.system(size: 17, weight: .light))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .foregroundStyle(.primary)
                    }
                    .buttonBorderShape(.capsule)
                    .GlassButtonIfAvailable()
                    .offset(x: isPad ? 50 : 30)
                    .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8)
                    .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                    .animation(.default, value: currentTimer.timerRunning)

                    Spacer()
                }
                .padding(.horizontal)
                .offset(y: isPad ? 80 : 72.5)
                
                // Stage Indicator
                StageIndicatorView(pageCount: AppState.speechTitles.count, currentPage: AppState.currentTabIndex, speechTypes: AppState.speechTypes)
                    .environmentObject(currentTimer)
                    .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.05 : 1.0)
                    .animation(.easeInOut, value: currentTimer.timerRunning)
                    .offset(y: isPad ? 30 : 75)
                
                // Tabview of TimerView instances according to AppState arrays
                TabView(selection: $AppState.currentTabIndex) {
                    ForEach(0..<AppState.speechTitles.count, id: \.self) { index in
                        TimerView(
                            speechTitle: AppState.speechTitles[index],
                            totalTime: AppState.speechTimes[index],
                            timerCode: currentTimer
                        )
                        .offset(y: isPad ? 18 : 0)
                        .tag(index)
                    }
                }
                .animation(.linear, value: timers.count)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(
                    swipeAllowed ? nil : Color.clear.contentShape(Rectangle())
                ) // Invisible overlay blocks swiping according to swipeAllowed
                .padding(isPad ? 0 : 10)
                .frame(height: isPad ? 520 : nil)
                .offset(y: !isPad && AppState.eventPrepTime == 0 ? 18 : 0)
                
                // Reset Button that interacts with current TimerCode instance
                ZStack {
                    // iPad layout
                    if isPad {
                        HStack {
                            // AFF Prep
                            Button(action: {
                                if AppState.eventPrepTime > 0 && !currentTimer.timerRunning {
                                    showAffPrep = true
                                }
                            }, label: {
                                Text("Prep\n\(formatMMSS(AppState.prepTimeAFF))")
                                    .font(.system(size: 22, weight: .semibold))
                                    .kerning(2)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(Color(hex: affColorHex))
                                    .frame(width: 120, height: 70)
                                    .background {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: affColorHex).opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(hex: affColorHex).opacity(0.6), lineWidth: 0.75)
                                            )
                                    }
                                    .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                                    .animation(.default, value: currentTimer.timerRunning)
                            })
                            .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))

                            Spacer()
                            
                            // NEG Prep
                            Button(action: {
                                if AppState.eventPrepTime > 0 && !currentTimer.timerRunning {
                                    showNegPrep = true
                                }
                            }, label: {
                                Text("Prep\n\(formatMMSS(AppState.prepTimeNEG))")
                                    .font(.system(size: 22, weight: .semibold))
                                    .kerning(2)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(Color(hex: negColorHex))
                                    .frame(width: 112, height: 70)
                                    .background {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: negColorHex).opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(hex: negColorHex).opacity(0.6), lineWidth: 0.75)
                                            )
                                    }
                                    .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                                    .animation(.default, value: currentTimer.timerRunning)
                            })
                            .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))
                        }
                        .padding(.horizontal, 170)
                    }

                    Button(action: {
                        if !currentTimer.timerRunning {
                            currentTimer.reset()
                            swipeAllowed = true
                            UIApplication.shared.isIdleTimerDisabled = currentTimer.timerRunning
                        }
                    }) {
                        Text("Reset")
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(Color.primary)
                            .background {
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Capsule()
                                        .fill(Color(.systemGray).opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.2))
                                        )
                                        .frame(width: 96, height: 46)
                                }
                            }
                            .opacity(currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8)
                    }
                    .allowsHitTesting(!(currentTimer.timerRunning && timerStageDimmingEnabled))
                }
                .offset(y: isPad ? (AppState.eventPrepTime > 0 ? 10 : 18) : (AppState.eventPrepTime > 0 ? -65 : -30))
                
                // Start/Stop button that interacts with current TimerCode instance
                Button(action: {
                    if currentTimer.timerRunning {
                        currentTimer.stop()
                        swipeAllowed = true
                    } else {
                        currentTimer.start()
                        swipeAllowed = false
                    }
                    UIApplication.shared.isIdleTimerDisabled = currentTimer.timerRunning
                }) {
                    Text(currentTimer.timerRunning ? "Stop" : "Start")
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 300, height: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 86)
                        .background {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                Circle()
                                    .fill(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.2), lineWidth: 0.7)
                                    )
                            }
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Capsule()
                                    .fill(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen").opacity(0.6), lineWidth: 0.75)
                                    )
                            }
                        }
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 25 : 34, weight: .light))
                        .foregroundStyle(Color(currentTimer.timerRunning ? "DangerRed" : "StartingGreen"))
                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 300, height: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 86)
                .contentShape(Capsule())
                .padding(.top, isPad ? 34 : 0)
                .padding(.bottom, isPad ? (AppState.eventPrepTime > 0 ? 92 : 104) : (AppState.eventPrepTime > 0 ? 90 : 110))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isPad ? .top : .center)
            
            // Prep time buttons
            HStack {
                
                // AFF Prep Time
                Button(action: {
                    if AppState.eventPrepTime > 0 && !currentTimer.timerRunning {
                        showAffPrep = true
                    }
                }, label: {
                    Text("Prep\n\(formatMMSS(AppState.prepTimeAFF))")
                        .font(.system(size: isPad ? 24 : 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: affColorHex))
                        .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                        .animation(.default, value: currentTimer.timerRunning)
                })
                .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))
                
                Spacer()
                
                // NEG Prep Time
                Button(action: {
                    if AppState.eventPrepTime > 0 && !currentTimer.timerRunning {
                        showNegPrep = true
                    }                }, label: {
                    Text("Prep\n\(formatMMSS(AppState.prepTimeNEG))")
                        .font(.system(size: isPad ? 24 : 20, weight: .semibold))
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: negColorHex))
                        .opacity(AppState.eventPrepTime > 0 ? (currentTimer.timerRunning && timerStageDimmingEnabled ? 0.1 : 0.8) : 0.0)
                        .animation(.default, value: currentTimer.timerRunning)
                })
                .allowsHitTesting(AppState.eventPrepTime > 0 && !(currentTimer.timerRunning && timerStageDimmingEnabled))
            }
            .padding(.horizontal, 75)
            .padding(.vertical, 75)
            .opacity(isPad ? 0.0 : 1.0)
            .allowsHitTesting(!isPad)
            .offset(y: 210)
        }
        .background(Color("BackgroundColor"))
        
        // End round alert
        .alert(isPresented: $showEndRoundConfirmation) {
            Alert(
                title: Text("End Round?"),
                message: Text("Are you sure you want to return to the event selection screen?"),
                primaryButton: .destructive(Text("End Round")) {
                    timers.forEach { $0.stop() }
                    UIApplication.shared.isIdleTimerDisabled = false
                    Task {
                        await PodiumTimerLiveActivityController.endAll()
                    }
                    AppState.view = "EventsView"

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true

                        withTransaction(transaction) {
                            AppState.prepTimeAFF = Int(AppState.eventPrepTime * 60)
                            AppState.prepTimeNEG = Int(AppState.eventPrepTime * 60)
                            AppState.timers = []
                            AppState.currentTabIndex = 0
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        
        // Prep Time Overlay Sheets
        .sheet(isPresented: $showAffPrep) {
            PrepTimeView(side: .aff, color: Color(hex: affColorHex), affRemainingSeconds: $AppState.prepTimeAFF, negRemainingSeconds: $AppState.prepTimeNEG, isPresented: $showAffPrep)
                .presentationDetents([.height(isPad ? 360 : 260)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNegPrep) {
            PrepTimeView(side: .neg, color: Color(hex: negColorHex), affRemainingSeconds: $AppState.prepTimeAFF, negRemainingSeconds: $AppState.prepTimeNEG, isPresented: $showNegPrep)
                .presentationDetents([.height(isPad ? 350 : 260)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = currentTimer.timerRunning
            Task {
                await PodiumTimerLiveActivityController.start(eventTitle: AppState.currentEvent)
            }

            // Configure protected time for the current speech when the view appears
            if AppState.speechTitles.indices.contains(AppState.currentTabIndex) {
                let minutes = AppState.protectedTimes.count == 1 && AppState.protectedTimes.first == 0 ? 0 : (AppState.currentTabIndex < AppState.protectedTimes.count ? AppState.protectedTimes[AppState.currentTabIndex] : 0)
                currentTimer.configureProtectedTime(minutesPerSide: minutes)
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: AppState.currentTabIndex) { _, newValue in
            // Reconfigure protected time whenever the user switches speeches
            let minutes = AppState.protectedTimes.count == 1 && AppState.protectedTimes.first == 0 ? 0 : (newValue < AppState.protectedTimes.count ? AppState.protectedTimes[newValue] : 0)
            currentTimer.configureProtectedTime(minutesPerSide: minutes)
        }
    }
}

#Preview {
        DebateView()
            .environmentObject(AppState())
}
