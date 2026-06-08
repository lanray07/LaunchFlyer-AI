import SwiftUI

struct CampaignCard: View {
    var title: String
    var type: String
    var style: VisualStyle
    var createdAt: Date

    var body: some View {
        GlassPanel(cornerRadius: 22) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: style.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 74, height: 92)
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                            .padding(10)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(type)
                        .font(.subheadline)
                        .foregroundStyle(.launchMint)
                    Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }
}
