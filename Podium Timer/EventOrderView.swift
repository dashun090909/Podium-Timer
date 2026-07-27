import SwiftUI
import UIKit

struct EventOrderView: View {
    @EnvironmentObject var AppState: AppState
    @AppStorage("eventOrder") private var storedEventOrder: String = ""

    @State private var eventOrder: [String] = []
    @State private var hasLoadedEventOrder = false

    var body: some View {
        VStack(alignment: .leading) {
            // Top bar
            HStack {
                Text("Reorder Events")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // X Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        AppState.eventOrder = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 26, height: 26)
                        .foregroundStyle(.primary)
                }
                .buttonBorderShape(.circle)
                .GlassButtonIfAvailable()
                .offset(x: 5)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.horizontal, 5)
            
            List {
                ForEach(eventOrder, id: \.self) { event in
                    HStack(spacing: 14) {
                        Text(event)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("RegressedColor").opacity(0.5))
                            .padding(.vertical, 4)
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
                .onMove(perform: moveEvents)
            }
            .environment(\.editMode, .constant(.active))
            .listStyle(.plain)
            .scrollIndicators(.never)
            .scrollContentBackground(.hidden)
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("BackgroundColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.7)
                )
                .shadow(radius: 10)
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.53)
        .padding(40)
        .onAppear(perform: loadEventOrder)
    }

    private func loadEventOrder() {
        guard !hasLoadedEventOrder else { return }
        eventOrder = orderedEvents(from: storedEventOrder)
        persistEventOrder()
        hasLoadedEventOrder = true
    }

    private func moveEvents(from source: IndexSet, to destination: Int) {
        eventOrder.move(fromOffsets: source, toOffset: destination)
        persistEventOrder()
    }

    private func persistEventOrder() {
        storedEventOrder = eventOrder.joined(separator: "|")
    }

    private func orderedEvents(from storedValue: String) -> [String] {
        let storedEvents = storedValue
            .split(separator: "|")
            .map(String.init)
            .filter { AppState.supportedEvents.contains($0) }

        return storedEvents + AppState.supportedEvents.filter { !storedEvents.contains($0) }
    }
}

#Preview {
        EventOrderView()
            .environmentObject(AppState())
}
