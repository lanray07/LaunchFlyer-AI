import SwiftUI

struct SocialPackPreview: View {
    var assets: [CampaignPackAsset]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(assets) { asset in
                    CampaignAssetPreview(
                        title: asset.headline,
                        subtitle: asset.subtitle,
                        assetType: asset.type,
                        style: asset.style
                    )
                    .frame(width: 170)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}
