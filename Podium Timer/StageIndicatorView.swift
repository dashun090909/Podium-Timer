import SwiftUI

struct StageIndicatorView: View {
    @EnvironmentObject var appState: AppState
    
    let pageCount: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            let baseWidth = 300.0 / (Double(pageCount) + 1.5)
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(Color.primary.opacity(index + 1 == currentPage ? 1.0 : 0.4)) // If current page, make opaque
                    .frame(width: index + 1 == currentPage ? baseWidth * 1.5 : baseWidth, height: 8) // If current page, make larger
            }
        }
        .animation(.snappy, value: currentPage)
        .padding(20)
    }
}

#Preview {
    StageIndicatorView(pageCount: 7, currentPage: 4)
        .padding()
        .environmentObject(AppState())
}
