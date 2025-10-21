import SwiftUI
import Combine

/// Ultra-performance variant of GlowEffect optimized for macOS battery saving mode
/// This version reduces blur layers and animation frequency for maximum performance
struct GlowEffectLowPower: View {
    @State private var gradientStops: [Gradient.Stop] = GlowEffectLowPower.generateGradientStops()
    @State private var timer: AnyCancellable?

    var body: some View {
        ZStack {
            EffectNoBlurLowPower(gradientStops: gradientStops, width: 6)
            EffectLowPower(gradientStops: gradientStops, width: 10, blur: 6)
        }
        .drawingGroup() // Composite layers into a single render pass
        .onAppear {
            // Slower update rate for better performance
            timer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    withAnimation(.easeInOut(duration: 1.5)) {
                        gradientStops = GlowEffectLowPower.generateGradientStops()
                    }
                }
        }
        .onDisappear {
            // Cancel timer to prevent memory leaks
            timer?.cancel()
            timer = nil
        }
    }

    // Function to generate random gradient stops
    static func generateGradientStops() -> [Gradient.Stop] {
        [
            Gradient.Stop(color: Color(hex: "BC82F3"), location: Double.random(in: 0...1)),
            Gradient.Stop(color: Color(hex: "F5B9EA"), location: Double.random(in: 0...1)),
            Gradient.Stop(color: Color(hex: "8D9FFF"), location: Double.random(in: 0...1)),
            Gradient.Stop(color: Color(hex: "FF6778"), location: Double.random(in: 0...1)),
            Gradient.Stop(color: Color(hex: "FFBA71"), location: Double.random(in: 0...1)),
            Gradient.Stop(color: Color(hex: "C686FF"), location: Double.random(in: 0...1))
        ].sorted { $0.location < $1.location }
    }
}

struct EffectLowPower: View {
    var gradientStops: [Gradient.Stop]
    var width: CGFloat
    var blur: CGFloat

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(stops: gradientStops),
                        center: .center
                    ),
                    lineWidth: width
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .blur(radius: blur)
                .compositingGroup() // Optimize blur rendering
        }
    }
}

struct EffectNoBlurLowPower: View {
    var gradientStops: [Gradient.Stop]
    var width: CGFloat

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(stops: gradientStops),
                        center: .center
                    ),
                    lineWidth: width
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    GlowEffectLowPower()
        .frame(width: 600, height: 400)
}
