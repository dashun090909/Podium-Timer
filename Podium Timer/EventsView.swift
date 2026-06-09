import SwiftUI

struct EventsView: View {
    @EnvironmentObject var AppState: AppState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("theme") private var theme: String = "Dark"
    
    @State private var settingsIconRotation = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                // Title and Settings button
                HStack(alignment: .center) {
                    HStack(spacing: 5) {
                        Text("Podium")
                            .font(.system(size: 35, weight: .heavy))
                        Text("Timer")
                            .font(.system(size: 35, weight: .heavy))
                            .opacity(0.5)
                    }
                    
                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            AppState.settings = true
                            settingsIconRotation += 45
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 38 : 30, weight: .semibold))
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(Double(settingsIconRotation)))
                    }
                    .offset(x: -10)
                }
                .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 20)
                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 110 : nil)
                
                List {
                    EventButton(eventTitle: "Big Questions", backgroundText: "BQ", backgroundTextOffset: -60, event: "Big Questions")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "Student Congress", backgroundText: "Con", backgroundTextOffset: -60, event: "Student Congress")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "Lincoln Douglas", backgroundText: "LD", backgroundTextOffset: -60, event: "Lincoln Douglas")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "Parliamentary", backgroundText: "Parli", backgroundTextOffset: -50, event: "Parliamentary")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "Policy", backgroundText: "CX", backgroundTextOffset: -80, event: "Policy")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "Public Forum", backgroundText: "PF", backgroundTextOffset: -80, event: "Public Forum")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))

                    EventButton(eventTitle: "World Schools", backgroundText: "WS", backgroundTextOffset: -80, event: "World Schools")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))
                    
                    // Spacer adds bottom padding via an empty row
                    Color.clear
                        .frame(height: 20)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .background(Color("BackgroundColor"))
                
                // Botom gradient
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("BackgroundColor").opacity(1),
                            Color("BackgroundColor").opacity(0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 40)
                    .allowsHitTesting(false)
                }
                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : 20)
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 44 : 24)
            .padding(.vertical, 30)
            
            // Top gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor").opacity(1),
                    Color("BackgroundColor").opacity(0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? 125 : 90)
            
            
            // Settings overlay
            ZStack {
                if AppState.settings {
                    ZStack {
                        Color.black.opacity(0.7).ignoresSafeArea()
                        
                        VStack {
                            Spacer()
                            SettingsView()
                            Spacer()
                        }
                        .frame(maxWidth: 600, maxHeight: 800)
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: AppState.settings)
        }
    }
}

struct EventButton: View {
    @EnvironmentObject var AppState: AppState
    @AppStorage("theme") private var theme: String = "Dark"
    var eventTitle: String
    var backgroundText: String
    var backgroundTextOffset: CGFloat
    var event: String

    private var cardContrastFill: Color {
        theme == "Light" ? Color.black.opacity(0.04) : Color.white.opacity(0.04)
    }

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AppState.currentEvent = event
                AppState.currentTabIndex = 0
                AppState.resetTimers()
                AppState.view = "DebateView"
            }
        }) {
            let label = ZStack(alignment: .leading) {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardContrastFill)
                        .frame(height: 95)
                        .overlay(
                            Text(backgroundText)
                                .font(.system(size: 160, weight: .bold))
                                .foregroundColor(Color.primary.opacity(0.06))
                                .rotationEffect(.degrees(20))
                                .offset(x: UIDevice.current.userInterfaceIdiom == .pad ? backgroundTextOffset + 150 : backgroundTextOffset)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(height: 95)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cardContrastFill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                        .overlay(
                            Text(backgroundText)
                                .font(.system(size: 160, weight: .bold))
                                .foregroundColor(Color.primary.opacity(0.06))
                                .rotationEffect(.degrees(20))
                                .offset(x: UIDevice.current.userInterfaceIdiom == .pad ? backgroundTextOffset + 150 : backgroundTextOffset)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .compositingGroup()
                }

                HStack {
                    Text(eventTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 30)
            }

            label
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .buttonStyle(EventPressStyle(cornerRadius: 20))
    }
}

private struct EventPressStyle: ButtonStyle {
    var cornerRadius: CGFloat = 20

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
        } else {
            configuration.label
                // Immediate visual feedback on touch-down
                .opacity(configuration.isPressed ? 0.72 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.black.opacity(configuration.isPressed ? 0.10 : 0.0))
                )
                .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
                .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
        }
    }
}

#Preview {
        EventsView()
            .environmentObject(AppState())
}
