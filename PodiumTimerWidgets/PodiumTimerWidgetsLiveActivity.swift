import ActivityKit
import WidgetKit
import SwiftUI

struct PodiumTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { }

    let title: String
}

struct PodiumTimerWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PodiumTimerAttributes.self) { context in
            ZStack {
                Text(abbreviation(for: context.attributes.title))
                    .font(.system(size: 130, weight: .bold))
                    .foregroundColor(Color.primary.opacity(0.2))
                    .fixedSize(horizontal: true, vertical: false)
                    .rotationEffect(.degrees(35))
                    .offset(x: 90)
                
                HStack{
                    VStack {
                        Text("Podium Timer")
                            .font(.system(size: 20, weight: .heavy))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 30)
                        
                        Text("Debate in progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)
                            .padding(.leading, 30)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxHeight: 90)
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text("Live")
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    private func abbreviation(for title: String) -> String {
        switch title {
        case "Big Questions":
            "BQ"
        case "Student Congress":
            "Con"
        case "Lincoln Douglas":
            "LD"
        case "Parliamentary":
            "Parli"
        case "Policy":
            "CX"
        case "Public Forum":
            "PF"
        case "World Schools":
            "WS"
        default:
            ""
        }
    }
}

extension PodiumTimerAttributes {
    static var preview: PodiumTimerAttributes {
        PodiumTimerAttributes(title: "Podium Timer")
    }
}

extension PodiumTimerAttributes.ContentState {
    static var preview: PodiumTimerAttributes.ContentState {
        PodiumTimerAttributes.ContentState()
    }
}

#Preview(
    "Lock Screen",
    as: .content,
    using: PodiumTimerAttributes.preview
) {
    PodiumTimerWidgetsLiveActivity()
} contentStates: {
    PodiumTimerAttributes.ContentState.preview
}
