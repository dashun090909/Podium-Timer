import SwiftUI

struct MainView: View {
    @EnvironmentObject var AppState: AppState

    @AppStorage("theme") private var theme: String = "Dark"
    
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
        .preferredColorScheme(theme == "Dark" ? .dark : .light)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8), value: AppState.view)
    }
}

#Preview {
        MainView()
            .environmentObject(AppState())
}
