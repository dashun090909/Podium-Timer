import ActivityKit
import Foundation

struct PodiumTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { }

    let title: String
}

enum PodiumTimerLiveActivityController {
    static func start(eventTitle: String) async {
        await endAll()

        let attributes = PodiumTimerAttributes(title: eventTitle)
        let content = ActivityContent(
            state: PodiumTimerAttributes.ContentState(),
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

    static func endAll() async {
        let finalContent = ActivityContent(
            state: PodiumTimerAttributes.ContentState(),
            staleDate: nil
        )

        for activity in Activity<PodiumTimerAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
}
