import ActivityKit
import Foundation

struct PodiumTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let isTimerRunning: Bool
        let remainingTime: TimeInterval
        let currentSpeechTitle: String
        let currentSpeechType: String
        let currentSide: String
    }

    let title: String
}

enum LiveActivityController {
    static func start(eventTitle: String, state: PodiumTimerAttributes.ContentState) async {
        await endAll()

        let attributes = PodiumTimerAttributes(title: eventTitle)
        let content = ActivityContent(
            state: state,
            staleDate: nil
        )

        do {
            _ = try Activity<PodiumTimerAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Unable to start Podium Timer Live Activity: \(error.localizedDescription)")
        }
    }

    static func update(state: PodiumTimerAttributes.ContentState) async {
        let content = ActivityContent(
            state: state,
            staleDate: nil
        )

        for activity in Activity<PodiumTimerAttributes>.activities {
            await activity.update(content)
        }
    }

    static func endAll() async {
        let finalContent = ActivityContent(
            state: PodiumTimerAttributes.ContentState.empty,
            staleDate: nil
        )

        for activity in Activity<PodiumTimerAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
}

extension PodiumTimerAttributes.ContentState {
    static let empty = PodiumTimerAttributes.ContentState(
        isTimerRunning: false,
        remainingTime: 0,
        currentSpeechTitle: "",
        currentSpeechType: "",
        currentSide: ""
    )
}
