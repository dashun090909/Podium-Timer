import SwiftUI

class AppState: ObservableObject {
    @Published var currentTabIndex: Int = 0
    @Published var speechTimes: [Double] = [360, 180, 420, 180, 240, 360, 180]
    @Published var speechTitles: [String] = ["AFF | 1AC", "AFF | CX", "NEG | 1NC", "NEG | CX", "AFF | 1AR", "NEG | 2NR", "AFF | 2AR"]
    @Published var speechTypes: [String] = ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "NEG", "AFF"]
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
