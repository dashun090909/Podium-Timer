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
                Text(side == .aff ? "AFF Prep" : "NEG Prep")
                    .font(.headline)
                    .foregroundStyle(color)
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill((running ? Color("DangerRed") : color).opacity(0.12))
                    )
                    .foregroundStyle(running ? Color("DangerRed") : color)
                    .font(.system(size: 20, weight: .semibold))
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))

            Spacer(minLength: 0)
        }
        .padding(.top, 40)
        .padding(20)
        .onDisappear { stop() }
        .interactiveDismissDisabled(running) // lock sheet while running
    }

    private func toggle() { running ? stop() : start() }

    private func start() {
        if running { return }
        running = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Allow negative to count overtime
            remainingSeconds.wrappedValue -= 1
        }
    }

    private func stop() {
        running = false
        timer?.invalidate()
        timer = nil
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
