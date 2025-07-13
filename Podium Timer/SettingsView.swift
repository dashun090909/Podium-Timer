import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var AppState: AppState
    
    @AppStorage("theme") private var theme: String = "Dark"
    @AppStorage("overtimeFlashEnabled") private var overtimeFlashEnabled: Bool = true
    @AppStorage("speakerIdentifierEnabled") private var speakerIdentifierEnabled: Bool = true
    @AppStorage("affColorHex") private var affColorHex: String = "#0D6FDE"
    @AppStorage("negColorHex") private var negColorHex: String = "#C42329"
    @AppStorage("warningThreshold") private var warningThreshold: Int = 30
    @AppStorage("dangerThreshold") private var dangerThreshold: Int = 10

    @State private var showingResetAlert = false

    @State private var warningMinutes: Int = 0
    @State private var warningSeconds: Int = 30
    @State private var dangerMinutes: Int = 0
    @State private var dangerSeconds: Int = 10
    @State private var showingWarningPicker = false
    @State private var showingDangerPicker = false

    private var affColorBinding: Binding<Color> {
        Binding<Color>(
            get: { Color(hex: affColorHex) },
            set: { affColorHex = $0.toHex() ?? affColorHex }
        )
    }

    private var negColorBinding: Binding<Color> {
        Binding<Color>(
            get: { Color(hex: negColorHex) },
            set: { negColorHex = $0.toHex() ?? negColorHex }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Top bar
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
                
                // X Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        AppState.settings = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 21))
                        .foregroundColor(.primary.opacity(0.5))
                }
            }
            .padding(.top, 15)
            .padding(.bottom, 5)
            .padding(.horizontal, 5)

            // Reset to Defaults Button
            Button("Reset to Defaults") {
                showingResetAlert = true
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("RegressedColor").opacity(0.5)))
            .padding(.bottom, 10)
            .alert("Reset to Defaults", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    resetToDefaults()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Reset all settings to default?")
            }
                        
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theme")
                        Picker("Theme", selection: $theme) {
                            Text("Light").tag("Light")
                            Text("Dark").tag("Dark")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Divider()
                        
                        HStack {
                            Text("Overtime Flash")
                            Spacer()
                            Toggle("", isOn: $overtimeFlashEnabled)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Speaker Identifier")
                            Spacer()
                            Toggle("", isOn: $speakerIdentifierEnabled)
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("RegressedColor").opacity(0.5)))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Timer Warnings")
                        
                        
                        HStack {
                            Text("Yellow Threshold")
                            Spacer()
                            Button("\(warningThreshold / 60)m \(warningThreshold % 60)s") {
                                showingWarningPicker = true
                            }
                        }

                        HStack {
                            Text("Red Threshold")
                            Spacer()
                            Button("\(dangerThreshold / 60)m \(dangerThreshold % 60)s") {
                                showingDangerPicker = true
                            }
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("RegressedColor").opacity(0.5)))
                    .sheet(isPresented: $showingWarningPicker) {
                        VStack {
                            Picker("Minutes", selection: Binding(get: {
                                warningThreshold / 60
                            }, set: {
                                warningThreshold = $0 * 60 + (warningThreshold % 60)
                            })) {
                                ForEach(0..<60) { Text("\($0) min").tag($0) }
                            }
                            .pickerStyle(.wheel)
                            Picker("Seconds", selection: Binding(get: {
                                warningThreshold % 60
                            }, set: {
                                warningThreshold = (warningThreshold / 60) * 60 + $0
                            })) {
                                ForEach(0..<60) { Text("\($0) sec").tag($0) }
                            }
                            .pickerStyle(.wheel)
                        }
                        .padding()
                        .presentationDetents([.height(300)])
                    }
                    .sheet(isPresented: $showingDangerPicker) {
                        VStack {
                            Picker("Minutes", selection: Binding(get: {
                                dangerThreshold / 60
                            }, set: {
                                dangerThreshold = $0 * 60 + (dangerThreshold % 60)
                            })) {
                                ForEach(0..<60) { Text("\($0) min").tag($0) }
                            }
                            .pickerStyle(.wheel)
                            Picker("Seconds", selection: Binding(get: {
                                dangerThreshold % 60
                            }, set: {
                                dangerThreshold = (dangerThreshold / 60) * 60 + $0
                            })) {
                                ForEach(0..<60) { Text("\($0) sec").tag($0) }
                            }
                            .pickerStyle(.wheel)
                        }
                        .padding()
                        .presentationDetents([.height(300)])
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ColorPicker("Affirmative Color", selection: affColorBinding)
                        
                        Divider()

                        ColorPicker("Negative Color", selection: negColorBinding)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("RegressedColor").opacity(0.5)))
                    
                    Text("Made by Dashun")
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                }
            }
            .scrollIndicators(.never)
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("BackgroundColor"))
                .shadow(radius: 10)
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
        .padding(20)
    }
    
    // Reset all settings to default values
    private func resetToDefaults() {
        theme = "Dark"
        overtimeFlashEnabled = true
        speakerIdentifierEnabled = true
        affColorHex = "#0D6FDE"
        negColorHex = "#C42329"
        warningThreshold = 30
        dangerThreshold = 10
    }
}

extension Color {
    init(hex: String) {
        let uiColor = UIColor(hex: hex)
        self = Color(uiColor)
    }

    func toHex() -> String? {
        UIColor(self).toHex()
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

#Preview {
        SettingsView()
            .environmentObject(AppState())
}
