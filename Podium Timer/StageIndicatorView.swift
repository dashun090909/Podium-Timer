import SwiftUI

struct StageIndicatorView: View {
    @EnvironmentObject var AppState: AppState
    
    @AppStorage("affColorHex") private var affColorHex: String = "#0D6FDE"
    @AppStorage("negColorHex") private var negColorHex: String = "#C42329"
    
    let pageCount: Int
    let currentPage: Int
    let speechTypes: [String?]?
    
    var body: some View {
        // Repeating capsules for each speech
        HStack(spacing: 8) {
            let baseWidth = 270 / (Double(pageCount) + 1.75)
            
            ForEach(0..<pageCount, id: \.self) { index in
                let isCurrent = index == currentPage
                let speechType = speechTypes?[index] ?? ""
                let fillColor: Color = {
                    switch speechType {
                    case "AFF", "AFFCX": return Color(hex: affColorHex)
                    case "NEG", "NEGCX": return Color(hex: negColorHex)
                    default: return Color.primary
                    }
                }()
                
                ZStack {
                    // Base capsule
                    Capsule()
                        .fill(fillColor.opacity(isCurrent ? 1.0 : 0.4))
                        .frame(width: isCurrent ? baseWidth * 1.75 : baseWidth, height: 8)
                    
                    // Diagonal strips if CX
                    if speechType.contains("CX") {
                        ZStack {
                            ForEach(0..<50, id: \.self) { j in
                                Rectangle()
                                    .fill(Color("BackgroundColor"))
                                    .frame(width: 3, height: 200)
                                    .rotationEffect(.degrees(45))
                                    .offset(x: CGFloat(j) * 15 - 83)
                            }
                        }
                        .frame(width: isCurrent ? baseWidth * 1.75 : baseWidth, height: 8)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .animation(.snappy, value: currentPage)
        .padding(20)
    }
}

#Preview {
    StageIndicatorView(
        pageCount: 11,
        currentPage: 4,
        speechTypes: ["AFF", "NEG", "FCX", "AFF", "NEG", "FCX", "AFF", "NEG", "GFCX", "AFF", "NEG"]
    )
    .environmentObject(AppState())
}
