import SwiftUI

struct EventsView: View {
    @EnvironmentObject var AppState: AppState
    
    @State private var settingsIconRotation = 0

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                // Title
                HStack {
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
                            .font(.title)
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(Double(settingsIconRotation)))
                    }
                    .offset(x: -10)
                }
                .offset(y: 20)

                ScrollView {
                    VStack(spacing: 20) {
                        EventButton(eventTitle: "Big Questions", backgroundText: "BQ", backgroundTextOffset: -60, event: "Big Questions")
                        
                        EventButton(eventTitle: "Student Congress", backgroundText: "Con", backgroundTextOffset: -60, event: "Congress")
                        
                        EventButton(eventTitle: "Lincoln Douglas", backgroundText: "LD", backgroundTextOffset: -60, event: "Lincoln Douglas")
                        
                        EventButton(eventTitle: "Parlimentary", backgroundText: "Parli", backgroundTextOffset: -80, event: "Parlimentary")
                        
                        EventButton(eventTitle: "Policy", backgroundText: "CX", backgroundTextOffset: -80, event: "Policy")
                        
                        EventButton(eventTitle: "Public Forum", backgroundText: "PF", backgroundTextOffset: -80, event: "Public Forum")
                        
                        EventButton(eventTitle: "World Schools", backgroundText: "WS", backgroundTextOffset: -80, event: "World Schools")

                        Spacer()
                        Spacer()
                    }
                    .offset(y: 20)
                }
                .scrollIndicators(.hidden)
            }
            .padding(30)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor").opacity(1),
                    Color("BackgroundColor").opacity(0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .offset(y: 90)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor").opacity(1),
                    Color("BackgroundColor").opacity(0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 40)
            .offset(y: 700)
            
            // Settings overlay
            ZStack {
                if AppState.settings {
                    ZStack {
                        Color.black.opacity(0.7).ignoresSafeArea()
                        
                        VStack {
                            Spacer()
                            SettingsView()
                                .shadow(radius: 10)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    var eventTitle: String
    var backgroundText: String
    var backgroundTextOffset: CGFloat
    var event: String

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AppState.currentEvent = event
                AppState.currentTabIndex = 0
                AppState.resetTimers()
                AppState.view = "DebateView"
            }
        }) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("RegressedColor"))
                    .frame(height: 95)
                    .overlay(
                        Text(backgroundText)
                            .font(.system(size: 160, weight: .bold))
                            .foregroundColor(Color.primary.opacity(0.05))
                            .rotationEffect(.degrees(20))
                            .offset(x: backgroundTextOffset)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

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
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
        EventsView()
            .environmentObject(AppState())
}
