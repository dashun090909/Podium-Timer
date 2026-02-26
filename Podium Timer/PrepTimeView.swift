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
    @State private var initialSecondsCaptured: Bool = false
    @State private var initialSeconds: Int = 0

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

            // Analog time and overtime indicator
            VStack(spacing: 6) {
                Text(analog(remainingSeconds.wrappedValue))
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .kerning(2)

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
                    .frame(height: 48)
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
            
            Spacer(minLength: 0)
        }
        .padding(.top, 40)
        .padding(20)
        .onAppear {
            if !initialSecondsCaptured {
                initialSeconds = remainingSeconds.wrappedValue
                initialSecondsCaptured = true
            }
        }
        .onDisappear { stop() }
        .interactiveDismissDisabled(running) // lock sheet while running
    }

    private func toggle() { running ? stop() : start() }

    private func start() {
        if running { return }
        running = true

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

        running = false
        timer?.invalidate()
        timer = nil
        startedAt = nil
    }

    private func resetPrep() {
        stop()
        remainingSeconds.wrappedValue = initialSeconds
    }

    private func updateRemainingFromClock() {
        guard running, let startedAt else { return }

        // Compute elapsed seconds based on wall-clock time.
        let elapsed = Int(Date().timeIntervalSince(startedAt).rounded(.down))

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
