import SwiftUI

struct TimerView: View {
    // Reference to TimerCode
    @EnvironmentObject var TimerCode: TimerCode
    
    var body: some View {
        VStack {
            // Title
            Text("AFF    |    1AC")
                .font(.title.bold())
                .offset(y: -60)
            
            // Timer circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color("RegressedColor"), lineWidth: 20)
                    .rotationEffect(Angle(degrees: -90))
                
                // Proggress bar
                Circle()
                    .trim(from: TimerCode.timerProgress, to: 1)
                    .stroke(Color("StartingGreen"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeIn, value:  TimerCode.timerProgress)
                    .shadow(color: Color("StartingGreen"), radius: 10)

                // Analog time
                Text(TimerCode.timerAnalog)
                    .font(.system(size: 50, weight: .light, design: .monospaced))
                    .kerning(3)
                    .animation(.none, value: TimerCode.timerAnalog)
            }
            
            // Start/Stop Button
            Button {} label: {
                Text(TimerCode.timerRunning ? "Stop" : "Start")
                    .frame(width: 110, height: 110)
                    .background {
                        Circle()
                            .fill(Color(TimerCode.timerRunning ? "OvertimeRed" : "StartingGreen").opacity(0.20))
                    }
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(Color(TimerCode.timerRunning ? "OvertimeRed" : "StartingGreen"))
                    .offset(y: 70)
            }
        }
        .frame(width: 300, height: 1000)
        .padding(1000)
        .background(Color("BackgroundColor"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerCode())
}
