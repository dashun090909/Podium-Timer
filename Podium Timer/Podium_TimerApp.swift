import SwiftUI

class AppState: ObservableObject {
    @Published var currentTabIndex: Int = 0
    @Published var eventType: String = "Lincoln Douglas"

    // Dictionary of Events : (Set of times, titles, and types)
    private let eventPresets: [String: (times: [Double], titles: [String], types: [String])] = [
        "Lincoln Douglas": (
            times: [6, 3, 7, 3, 4, 6, 3],
            titles: ["1AC", "CX", "1NC", "CX", "1AR", "2NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "NEG", "AFF"]
        ),
        "Policy": (
            times: [8, 3, 8, 3, 5, 5, 5, 5],
            titles: ["1AC", "CX", "1NC", "CX", "2AC", "2NC", "1NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "NEG", "NEG", "AFF"]
        )
    ]

    var speechTimes: [Double] {
        eventPresets[eventType]?.times ?? []
    }

    var speechTitles: [String] {
        eventPresets[eventType]?.titles ?? []
    }

    var speechTypes: [String] {
        eventPresets[eventType]?.types ?? []
    }
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
