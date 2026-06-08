import SwiftUI

struct CampaignAssetPreview: View {
    var title: String
    var subtitle: String
    var assetType: CampaignAssetType
    var style: VisualStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: style.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .aspectRatio(assetType.aspectRatio, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.74))
                            .lineLimit(2)
                    }
                    .padding(14)
                }
                .overlay(alignment: .topTrailing) {
                    Text(assetType.rawValue)
                        .font(.caption2.bold())
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.34), in: Capsule())
                        .foregroundStyle(.white)
                        .padding(10)
                }

            Text(assetType.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}
