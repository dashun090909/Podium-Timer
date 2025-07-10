import SwiftUI

class AppState: ObservableObject {
    @Published var currentTabIndex: Int = 0
}

@main
struct Podium_TimerApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            LDView()
                .environmentObject(appState)
        }
    }
}
