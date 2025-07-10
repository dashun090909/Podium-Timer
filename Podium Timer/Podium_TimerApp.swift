import SwiftUI

class AppState: ObservableObject {
    @Published var currentTabIndex: Int = 0
    @Published var eventType: String = "Lincoln Douglas"

    // Dictionary of Events : (Set of times, titles, and types)
    private let eventPresets: [String: (times: [Double], titles: [String], types: [String], speakers: [String])] = [
        "Lincoln Douglas": (
            times: [6, 3, 7, 3, 4, 6, 3],
            titles: ["1AC", "CX", "1NC", "CX", "1AR", "2NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "NEG", "AFF"],
            speakers: []
        ),
        "Public Forum": (
            times: [4, 4, 3, 4, 4, 3, 3, 3, 3, 2, 2],
            titles: ["AFF Constructive", "NEG Constructive", "1st Crossfire", "AFF Rebuttal", "NEG Rebuttal", "2nd Crossfire", "AFF Summary", "NEG Summary", "Grand Crossfire", "AFF Final Focus", "NEG Final Focus"],
            types: ["AFF", "NEG", "FCX", "AFF", "NEG", "FCX", "AFF", "NEG", "GFCX", "AFF", "NEG"],
            speakers: ["1st AFF Speaker", "1st NEG Speaker", "1st Speakers", "2nd AFF Speaker", "2nd NEG Speaker", "2nd Speakers", "1st AFF Speaker", "1st NEG Speaker", "All Speakers", "2nd AFF Speaker", "2nd NEG Speaker"]
        ),
        "Policy": (
            times: [8, 3, 8, 3, 8, 3, 8, 3, 5, 5, 5, 5],
            titles: ["1AC", "CX", "1NC", "CX", "2AC", "CX", "2NC", "CX", "1NR", "1AR", "2NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "AFFCX", "NEG", "NEGCX", "NEG", "AFF", "NEG", "AFF"],
            speakers: ["1st AFF Speaker", "1st AFF Speaker\n2nd NEG Speaker", "1st NEG Speaker", "1st NEG Speaker\n1st AFF Speaker", "2nd AFF Speaker", "2nd AFF Speaker\n1st NEG Speaker", "2nd NEG Speaker", "2nd NEG Speaker\n2nd AFF Speaker", "1st NEG Speaker", "1st AFF Speaker", "2nd NEG Speaker", "2nd AFF Speaker"]
        ),
        "Parlimentary": (
            times: [7, 8, 8, 8, 4, 5],
            titles: ["1st AFF Constructive", "1st NEG Constructive", "2nd AFF Constructive", "2nd NEG Constructive", "NEG Rebuttal", "AFF Rebuttal"],
            types: ["AFF", "NEG", "AFF", "NEG", "NEG", "AFF"],
            speakers: ["1st AFF Speaker", "1st NEG Speaker", "2nd AFF Speaker", "2nd NEG Speaker", "1st NEG Speaker", "1st AFF Speaker"]
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
    
    var speechSpeakers: [String] {
        eventPresets[eventType]?.speakers ?? []
    }
}

@main
struct Podium_TimerApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            DebateView()
                .environmentObject(appState)
        }
    }
}
