import SwiftUI

extension Color {
    static let launchInk = Color(hex: "#070A12")
    static let launchGraphite = Color(hex: "#171923")
    static let launchElectric = Color(hex: "#7C5CFF")
    static let launchMint = Color(hex: "#60F5C8")
    static let launchBerry = Color(hex: "#FF3D81")
    static let launchGold = Color(hex: "#F8D66D")
    static let launchOrange = Color(hex: "#FF8A3D")
    static let launchRose = Color(hex: "#FFB3C7")
    static let launchSilver = Color(hex: "#D8DEE9")

    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch clean.count {
        case 6:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
        default:
            red = 255
            green = 255
            blue = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}

extension ShapeStyle where Self == Color {
    static var launchInk: Color { Color.launchInk }
    static var launchGraphite: Color { Color.launchGraphite }
    static var launchElectric: Color { Color.launchElectric }
    static var launchMint: Color { Color.launchMint }
    static var launchBerry: Color { Color.launchBerry }
    static var launchGold: Color { Color.launchGold }
    static var launchOrange: Color { Color.launchOrange }
    static var launchRose: Color { Color.launchRose }
    static var launchSilver: Color { Color.launchSilver }
}

struct PremiumBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .launchInk, .launchGraphite],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.launchElectric.opacity(0.32), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.launchMint.opacity(0.18), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }
}

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 24, x: 0, y: 16)
    }
}

struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [.launchMint, .launchGold], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(configuration.isPressed ? 0.16 : 0.1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

struct SectionHeader: View {
    var eyebrow: String
    var title: String
    var actionTitle: String?

    init(_ eyebrow: String, title: String, actionTitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.actionTitle = actionTitle
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.launchMint)
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            Spacer()
            if let actionTitle {
                Text(actionTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.launchSilver)
            }
        }
    }
}

struct MetricPill: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        GlassPanel(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.launchMint)
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
