import SwiftUI

struct PrepTimeView: View {
    enum Side { case aff, neg }

    let side: Side
    let color: Color

    // Remaining seconds for AFF and NEG, persisted/owned by caller
    @Binding var affRemainingSeconds: Int
    @Binding var negRemainingSeconds: Int

    // Controls whether the sheet can be dismissed (managed by caller)
    @Binding var isPresented: Bool

    // Local running state
    @State private var running: Bool = false
    @State private var timer: Timer?

    // Wall-clock based timing so prep continues accurately after background/lock
    @State private var startedAt: Date?
    @State private var startingRemainingSeconds: Int = 0

    // Reset handling
    @State private var showResetConfirm: Bool = false

    // Persisted full-prep baselines so Reset works across sheet reopen
    @AppStorage("prepBaselineAffSeconds") private var baselineAffSeconds: Int = 0
    @AppStorage("prepBaselineNegSeconds") private var baselineNegSeconds: Int = 0

    // Tracks how long prep ran continuously the last time it was started
    @State private var lastRunElapsedSeconds: Int = 0

    // Enables a short numeric-text animation when the timer is reset
    @State private var resetPeriod: Bool = false

    // Computed binding to the correct side's remainingSeconds
    private var remainingSeconds: Binding<Int> {
        switch side {
        case .aff:
            return $affRemainingSeconds
        case .neg:
            return $negRemainingSeconds
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Header
            HStack {
                
                // Reset Button
                Button {
                    showResetConfirm = true
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(color.opacity(0.12))
                        )
                        .overlay(
                            Circle()
                                .stroke((running ? Color("DangerRed") : color).opacity(0.3), lineWidth: 1)
                                .opacity(0.6)
                        )
                }
                .buttonStyle(.plain)
                .glassIfAvailable()
                .disabled(running)
                .opacity(running ? 0.35 : 1.0)
                .padding(.leading, 5)

                Spacer()
            }
            
            // Prep Time Menu Title
            .overlay {
                Text(side == .aff ? "AFF Prep" : "NEG Prep")
                    .font(.headline)
                    .foregroundStyle(color)
            }
            .alert("Reset prep time?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetPrep()
                }
            } message: {
                Text("This will reset the prep timer back to its starting value.")
            }

            // Last used (previous continuous run duration)
            Text("Last used: \(formatElapsed(lastRunElapsedSeconds))")
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .opacity(running ? 0.45 : 1.0)

            // Analog time and overtime indicator
            VStack(spacing: 6) {
                Text(analog(remainingSeconds.wrappedValue))
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .kerning(2)
                    .contentTransition(.numericText())
                    .animation(
                        resetPeriod ? .easeInOut(duration: 0.25) : nil,
                        value: remainingSeconds.wrappedValue
                    )

                Text(remainingSeconds.wrappedValue < 0 ? "OVERTIME" : "")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color("DangerRed"))
                    .animation(.easeInOut, value: remainingSeconds.wrappedValue < 0)
            }
            .frame(maxWidth: .infinity)

            // Start/Stop button
            Button(action: toggle) {
                Text(running ? "Stop" : "Start")
                    .frame(maxWidth: 350)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill((running ? Color("DangerRed") : color).opacity(0.12))

                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke((running ? Color("DangerRed") : color).opacity(0.3), lineWidth: 1)
                            .opacity(0.6)
                    )
                    .foregroundStyle(running ? Color("DangerRed") : color)
                    .font(.system(size: 20, weight: .semibold))
            }
            .glassIfAvailable()
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .offset(y: -10)
            
            Spacer(minLength: 10)
        }
        .padding(.top, 60)
        .padding(20)
        .onAppear {
            // Establish baselines without capturing an already-elapsed value.
            // If baseline is unset (0), use the current value.
            // If current value is larger than baseline (e.g., settings increased), update baseline.
            if baselineAffSeconds == 0 {
                baselineAffSeconds = affRemainingSeconds
            } else if affRemainingSeconds > baselineAffSeconds {
                baselineAffSeconds = affRemainingSeconds
            }

            if baselineNegSeconds == 0 {
                baselineNegSeconds = negRemainingSeconds
            } else if negRemainingSeconds > baselineNegSeconds {
                baselineNegSeconds = negRemainingSeconds
            }
        }
        .onDisappear { stop() }
        .interactiveDismissDisabled(running) // lock sheet while running
        .offset(y: -10)
    }

    private func toggle() { running ? stop() : start() }

    private func start() {
        if running { return }
        running = true

        // Reset last-used counter at the start of a new continuous run
        lastRunElapsedSeconds = 0

        // Capture baseline and wall-clock start so we can "catch up" after backgrounding.
        startingRemainingSeconds = remainingSeconds.wrappedValue
        startedAt = Date()

        timer?.invalidate()
        // Use a small interval for responsive UI; accuracy comes from wall-clock time.
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            updateRemainingFromClock()
        }

        // Update immediately so UI reflects the running state without waiting for first tick.
        updateRemainingFromClock()
    }

    private func stop() {
        // Snap remaining time to the correct wall-clock value before stopping.
        updateRemainingFromClock()

        if let startedAt {
            lastRunElapsedSeconds = Int(Date().timeIntervalSince(startedAt).rounded(.down))
        }

        running = false
        timer?.invalidate()
        timer = nil
        startedAt = nil
    }

    private func resetPrep() {
        stop()
        let baseline = (side == .aff) ? baselineAffSeconds : baselineNegSeconds
        switch side {
        case .aff:
            affRemainingSeconds = baseline
        case .neg:
            negRemainingSeconds = baseline
        }

        // Trigger a short-lived animation window for the analog time
        resetPeriod = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            resetPeriod = false
        }
    }

    private func updateRemainingFromClock() {
        guard running, let startedAt else { return }

        // Compute elapsed seconds based on wall-clock time.
        let elapsed = Int(Date().timeIntervalSince(startedAt).rounded(.down))

        // Tick up the last-used counter while running
        lastRunElapsedSeconds = elapsed

        // Allow negative to count overtime.
        remainingSeconds.wrappedValue = startingRemainingSeconds - elapsed
    }

    private func analog(_ seconds: Int) -> String {
        let absVal = abs(seconds)
        let m = absVal / 60
        let s = absVal % 60
        let base = String(format: "%02d:%02d", m, s)
        return seconds < 0 ? "-" + base : base
    }

    private func formatElapsed(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        let m = clamped / 60
        let s = clamped % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    @Previewable @State var aff = 240
    @Previewable @State var neg = 300
    @Previewable @State var presented = true
    VStack {
        PrepTimeView(side: .aff, color: .blue, affRemainingSeconds: $aff, negRemainingSeconds: $neg, isPresented: $presented)
        PrepTimeView(side: .neg, color: .red, affRemainingSeconds: $aff, negRemainingSeconds: $neg, isPresented: $presented)
    }
}
