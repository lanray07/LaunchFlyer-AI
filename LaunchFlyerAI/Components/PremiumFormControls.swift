import SwiftUI

struct PremiumTextEditor: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 118

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.62))
                .textCase(.uppercase)

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .padding(12)
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.white.opacity(0.38))
                            .padding(.top, 20)
                            .padding(.leading, 17)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

struct FormChip: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(.white.opacity(0.1), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct PremiumToggleRow: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.58))
            }
        }
        .tint(.launchMint)
    }
}
