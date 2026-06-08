import SwiftData
import SwiftUI

struct CampaignLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Campaign.createdAt, order: .reverse) private var campaigns: [Campaign]

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader("Library", title: "Campaigns and drafts")
                    if campaigns.isEmpty {
                        EmptyStateView(title: "Your library is ready", subtitle: "Campaigns, drafts, assets, and templates will be stored offline here.", icon: "folder")
                    } else {
                        ForEach(campaigns) { campaign in
                            CampaignCard(
                                title: campaign.title,
                                type: campaign.campaignType,
                                style: VisualStyle(rawValue: campaign.style) ?? .electric,
                                createdAt: campaign.createdAt
                            )
                            .contextMenu {
                                Button("Duplicate campaign", systemImage: "plus.square.on.square") {
                                    duplicate(campaign)
                                }
                                Button("Archive campaign", systemImage: "archivebox", role: .destructive) {
                                    modelContext.delete(campaign)
                                    try? modelContext.save()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Library")
    }

    private func duplicate(_ campaign: Campaign) {
        modelContext.insert(
            Campaign(
                title: "\(campaign.title) Copy",
                campaignType: campaign.campaignType,
                brief: campaign.brief,
                style: campaign.style
            )
        )
        try? modelContext.save()
    }
}
