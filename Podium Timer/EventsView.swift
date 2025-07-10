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
                        Button(action: {
                            navigate(event: "Big Questions")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("BQ")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -60)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Big Questions")
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
                        
                        Button(action: {
                            navigate(event: "Congress")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("Con")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -60)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Congress Speech")
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
                        
                        Button(action: {
                            navigate(event: "Lincoln Douglas")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("LD")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -60)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Lincoln Douglas")
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
                        
                        Button(action: {
                            navigate(event: "Parlimentary")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("Parli")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -80)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Parlimentary")
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

                        Button(action: {
                            navigate(event: "Policy")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("CX")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -80)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Policy")
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

                        Button(action: {
                            navigate(event: "Public Forum")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("PF")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -80)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("Public Forum")
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
                        
                        Button(action: {
                            navigate(event: "World Schools")
                        }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("RegressedColor"))
                                    .frame(height: 95)
                                    .overlay(
                                        Text("WS")
                                            .font(.system(size: 160, weight: .bold))
                                            .foregroundColor(Color.primary.opacity(0.05))
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -80)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack {
                                    Text("World Schools")
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
            .offset(y: 690)
        }
    }

    func navigate(event: String) {
        AppState.currentEvent = event
        AppState.currentTabIndex = 0
        AppState.view = "DebateView"
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView().environmentObject(AppState())
    }
}
