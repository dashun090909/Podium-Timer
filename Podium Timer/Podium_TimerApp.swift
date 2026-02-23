import SwiftUI

class AppState: ObservableObject {
    @Published var currentTabIndex: Int = 0
    @Published var currentEvent: String = "Lincoln Douglas"
    @Published var view: String = "EventsView"
    @Published var settings: Bool = false
    @Published var timers: [TimerCode] = []
    @AppStorage("prepTimeAFF") var prepTimeAFF: Int = 240
    @AppStorage("prepTimeNEG") var prepTimeNEG: Int = 240

    // Dictionary of Events : (Set of times, titles, and types)
    private let eventPresets: [String: (times: [Double], titles: [String], types: [String], speakers: [String], prepTime: Double)] = [
        "Big Questions": (
            times: [5, 5, 3, 4, 4, 3, 3, 3, 2, 2],
            titles: ["AFF Constructive", "Neg Constructive", "Question Segment", "AFF Rebuttal", "NEG Rebuttal", "Question Segment", "AFF Consolidation", "NEG Consolidation", "AFF Rationale", "NEG Rationale"],
            types: ["AFF", "NEG", "QCX", "AFF", "NEG", "QCX", "AFF", "NEG", "AFF", "NEG"],
            speakers: [],
            prepTime: 3
        ),
        "Student Congress": (
            times: [3, 1],
            titles: ["Speech", "Cross-Examination"],
            types: ["AFF", "CX"],
            speakers: [],
            prepTime: 0
        ),
        "Lincoln Douglas": (
            times: [6, 3, 7, 3, 4, 6, 3],
            titles: ["1AC", "CX", "1NC", "CX", "1AR", "2NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "NEG", "AFF"],
            speakers: [],
            prepTime: 4
        ),
        "Parlimentary": (
            times: [7, 7, 7, 7, 5, 5],
            titles: ["1st PROP", "1st OPP", "2nd PROP", "2nd OPP", "3rd OPP", "3rd PROP"],
            types: ["AFF", "NEG", "AFF", "NEG", "NEG", "AFF"],
            speakers: ["1st AFF Speaker", "1st NEG Speaker", "2nd AFF Speaker", "2nd NEG Speaker", "1st NEG Speaker", "1st AFF Speaker"],
            prepTime: 0
        ),
        "Policy": (
            times: [8, 3, 8, 3, 8, 3, 8, 3, 5, 5, 5, 5],
            titles: ["1AC", "CX", "1NC", "CX", "2AC", "CX", "2NC", "CX", "1NR", "1AR", "2NR", "2AR"],
            types: ["AFF", "AFFCX", "NEG", "NEGCX", "AFF", "AFFCX", "NEG", "NEGCX", "NEG", "AFF", "NEG", "AFF"],
            speakers: ["1st AFF Speaker", "1st AFF Speaker\n2nd NEG Speaker", "1st NEG Speaker", "1st NEG Speaker\n1st AFF Speaker", "2nd AFF Speaker", "2nd AFF Speaker\n1st NEG Speaker", "2nd NEG Speaker", "2nd NEG Speaker\n2nd AFF Speaker", "1st NEG Speaker", "1st AFF Speaker", "2nd NEG Speaker", "2nd AFF Speaker"],
            prepTime: 8
        ),
        "Public Forum": (
            times: [4, 4, 3, 4, 4, 3, 3, 3, 3, 2, 2],
            titles: ["AFF Constructive", "NEG Constructive", "1st Crossfire", "AFF Rebuttal", "NEG Rebuttal", "2nd Crossfire", "AFF Summary", "NEG Summary", "Grand Crossfire", "AFF Final Focus", "NEG Final Focus"],
            types: ["AFF", "NEG", "FCX", "AFF", "NEG", "FCX", "AFF", "NEG", "GFCX", "AFF", "NEG"],
            speakers: ["1st AFF Speaker", "1st NEG Speaker", "1st Speakers", "2nd AFF Speaker", "2nd NEG Speaker", "2nd Speakers", "1st AFF Speaker", "1st NEG Speaker", "All Speakers", "2nd AFF Speaker", "2nd NEG Speaker"],
            prepTime: 3
        ),
        "World Schools": (
            times: [8, 8, 8, 8, 8, 8, 4, 4],
            titles: ["1st PROP", "1st OPP", "2nd PROP", "2nd OPP", "3rd PROP", "3rd OPP", "OPP Reply", "PROP Reply"],
            types: ["AFF", "NEG", "AFF", "NEG", "AFF", "NEG", "NEG", "AFF"],
            speakers: ["1st Prop Speaker", "1st OPP Speaker", "2nd PROP Speaker", "2nd OPP Speaker", "1st/2nd PROP Speaker", "1st/2nd OPP Speaker"],
            prepTime: 0
        ),
    ]

    var speechTimes: [Double] {
        eventPresets[currentEvent]?.times ?? []
    }

    var speechTitles: [String] {
        eventPresets[currentEvent]?.titles ?? []
    }

    var speechTypes: [String] {
        eventPresets[currentEvent]?.types ?? []
    }
    
    var speechSpeakers: [String] {
        eventPresets[currentEvent]?.speakers ?? []
    }
    
    var eventPrepTime: Double {
        eventPresets[currentEvent]?.prepTime ?? 0
    }

    func resetTimers() {
        // Initialize speech timers
        self.timers = self.speechTimes.map { TimerCode(totalTime: $0 * 60) }
        // Initialize prep time for both sides from event preset (minutes -> seconds)
        let seconds = Int(self.eventPrepTime * 60)
        self.prepTimeAFF = seconds
        self.prepTimeNEG = seconds
    }
}

@main
struct Podium_TimerApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
    }
}

