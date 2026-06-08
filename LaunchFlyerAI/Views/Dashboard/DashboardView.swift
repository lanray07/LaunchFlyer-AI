import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var services: AppServices
    @Query(sort: \Campaign.createdAt, order: .reverse) private var campaigns: [Campaign]
    @Query(sort: \ExportRecord.createdAt, order: .reverse) private var exports: [ExportRecord]
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingPaywall = false

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    UpgradeBanner { showingPaywall = true }
                    subscriptionStatus
                    metrics
                    quickActions
                    recentCampaigns
                    trendingTemplates
                    suggestions
                }
                .padding()
            }
        }
        .navigationTitle("Studio")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.greeting())
                .font(.caption.weight(.bold))
                .foregroundStyle(.launchMint)
                .textCase(.uppercase)
            Text("One idea. Complete campaign.")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text("Create flyers, posters, captions, hashtags, and social-ready packs from a prompt or voice brief.")
                .foregroundStyle(.white.opacity(0.66))
        }
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricPill(title: "Campaigns", value: "\(campaigns.count)", icon: "megaphone.fill")
            MetricPill(title: "Exports", value: "\(exports.count)", icon: "square.and.arrow.up.fill")
        }
    }

    private var subscriptionStatus: some View {
        GlassPanel(cornerRadius: 20) {
            HStack(spacing: 14) {
                Image(systemName: services.subscriptionService.isActive ? "checkmark.seal.fill" : "crown.fill")
                    .font(.title2)
                    .foregroundStyle(services.subscriptionService.isActive ? .launchMint : .launchGold)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(services.subscriptionService.currentPlan.rawValue) Plan")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(services.subscriptionService.currentPlan.includedFeatures.joined(separator: " / "))
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.white.opacity(0.58))
                }
                Spacer()
            }
        }
        .task {
            await services.subscriptionService.loadProducts()
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Fast actions", title: "Build the next asset")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionLink(title: "Create Campaign", icon: "wand.and.stars", destination: CampaignPromptView())
                QuickActionLink(title: "Voice Campaign", icon: "waveform", destination: VoiceCampaignBuilderView())
                QuickActionLink(title: "Make Flyer", icon: "doc.text.image", destination: FlyerDesignerView())
                QuickActionLink(title: "Social Pack", icon: "square.grid.2x2.fill", destination: SocialMediaPackBuilderView())
                QuickActionLink(title: "Event Pack", icon: "calendar.badge.plus", destination: EventPackBuilderView())
                QuickActionLink(title: "Brand Kit", icon: "paintpalette.fill", destination: BrandKitView())
                QuickActionLink(title: "AI Copywriter", icon: "text.quote", destination: AICopywriterView())
                QuickActionLink(title: "Preview Studio", icon: "iphone.gen2", destination: CampaignPreviewStudioView())
                QuickActionLink(title: "Export Center", icon: "square.and.arrow.up", destination: ExportCenterView())
                QuickActionLink(title: "Analytics", icon: "chart.bar.xaxis", destination: AnalyticsView())
            }
        }
    }

    private var recentCampaigns: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Recent", title: "Campaigns", actionTitle: campaigns.isEmpty ? nil : "View all")
            if campaigns.isEmpty {
                EmptyStateView(title: "No campaigns yet", subtitle: "Generate your first launch pack from a prompt or voice idea.", icon: "sparkles")
            } else {
                ForEach(campaigns.prefix(3)) { campaign in
                    CampaignCard(
                        title: campaign.title,
                        type: campaign.campaignType,
                        style: VisualStyle(rawValue: campaign.style) ?? .electric,
                        createdAt: campaign.createdAt
                    )
                }
            }
        }
    }

    private var trendingTemplates: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Trending", title: "Premium templates")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(services.templateCatalog.templates.filter(\.isFeatured)) { template in
                        TemplateCard(template: template)
                            .frame(width: 220)
                    }
                }
            }
        }
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("AI", title: "Suggestions")
            ForEach(viewModel.aiSuggestions, id: \.self) { suggestion in
                GlassPanel(cornerRadius: 18) {
                    Label(suggestion, systemImage: "sparkle")
                        .foregroundStyle(.white)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct QuickActionLink<Destination: View>: View {
    var title: String
    var icon: String
    var destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            GlassPanel(cornerRadius: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.launchMint)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                }
                .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        GlassPanel {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(.launchMint)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
