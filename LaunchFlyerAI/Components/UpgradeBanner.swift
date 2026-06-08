import SwiftUI

struct UpgradeBanner: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.black)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Creator Plan")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                    Text("Unlock premium templates and exports")
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.68))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.black.opacity(0.7))
            }
            .padding()
            .background(
                LinearGradient(colors: [.launchMint, .launchGold], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}
