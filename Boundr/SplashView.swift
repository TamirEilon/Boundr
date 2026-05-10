import SwiftUI

struct SplashView: View {
    var onSettled: () -> Void

    @State private var startDate: Date? = nil
    @State private var paused = true

    private let brandBlue  = Color(red: 38/255,  green: 99/255,  blue: 235/255)
    private let dotColor   = Color(red: 143/255, green: 166/255, blue: 236/255)
    private let dotSize: CGFloat = 15

    // Physics parameters
    private let h0: Double = 800
    private let e: Double  = 0.70
    private let fallDuration: Double = 0.45
    private let bounceCount = 5

    private var totalDuration: Double {
        (1...bounceCount).reduce(fallDuration) { acc, i in
            acc + 2 * pow(e, Double(i)) * fallDuration
        }
    }

    private func dotY(at elapsed: Double) -> CGFloat {
        var t = min(elapsed, totalDuration)

        let g0 = 2 * h0 / (fallDuration * fallDuration)
        if t <= fallDuration {
            return CGFloat(-(h0 - 0.5 * g0 * t * t))
        }
        t -= fallDuration

        for i in 1...bounceCount {
            let bounceH   = h0 * pow(e * e, Double(i))
            let bounceDur = 2 * pow(e, Double(i)) * fallDuration
            if t <= bounceDur {
                let halfT = bounceDur / 2.0
                let gB    = 2 * bounceH / (halfT * halfT)
                let dt    = t - halfT
                return CGFloat(-max(0, bounceH - 0.5 * gB * dt * dt))
            }
            t -= bounceDur
        }
        return 0
    }

    var body: some View {
        ZStack {
            brandBlue.ignoresSafeArea()

            // .lastTextBaseline aligns the dot's bottom to the B's baseline,
            // which matches the visual bottom of the capital letter.
            HStack(alignment: .lastTextBaseline, spacing: -12) {
                Text("B")
                    .font(.custom("DM Sans", size: 100))
                    .fontWeight(.black)
                    .foregroundColor(.white)

                TimelineView(.animation(paused: paused)) { context in
                    let elapsed = startDate.map { context.date.timeIntervalSince($0) } ?? 0
                    Circle()
                        .fill(dotColor)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3.1))
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: dotY(at: elapsed))
                }
            }
        }
        .onAppear {
            let delay = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                startDate = Date()
                paused = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + totalDuration + 0.05) {
                paused = true
                onSettled()
            }
        }
    }
}

#Preview {
    SplashView(onSettled: {})
}
