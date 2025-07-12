import SwiftUI

struct MainView: View {
    @EnvironmentObject var AppState: AppState

    var body: some View {
        ZStack {
            if AppState.view == "DebateView" {
                DebateView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                EventsView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8), value: AppState.view)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState())
    }
}
