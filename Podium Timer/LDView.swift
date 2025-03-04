import SwiftUI

struct LDView: View {
    @State private var swipeAllowed: Bool = true // Controls if swiping is allowed (to prevent swiping to other timers while running)

    var body: some View {
        ZStack {
            TabView {
                TimerView(speechTitle: "AFF | 1AC", totalTime: 10, swipeAllowed: $swipeAllowed)
                    .gesture(swipeAllowed ? nil : DragGesture())  // Blocks drag gesture if swiping is disabled
                TimerView(speechTitle: "NEG | 1NC", totalTime: 20, swipeAllowed: $swipeAllowed)
                    .gesture(swipeAllowed ? nil : DragGesture())  // Blocks drag gesture if swiping is disabled
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 50)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LDView()
}
