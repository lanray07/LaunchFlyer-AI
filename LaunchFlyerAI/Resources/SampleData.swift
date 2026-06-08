import Foundation

enum SampleData {
    static let generatedCampaign = GeneratedCampaign(
        campaignConcept: "A premium campaign pack for a weekend launch, using vivid contrast, short copy, and one decisive CTA.",
        headlines: [
            "Launch anything in minutes.",
            "One idea. Complete campaign.",
            "Make the moment impossible to miss."
        ],
        flyerCopy: "Bring your launch to life with premium flyers, captions, hashtags, and social formats generated from one idea.",
        socialCaptions: [
            "The launch is live. Save the date and bring someone with you.",
            "One weekend. One offer. A complete campaign built to move."
        ],
        hashtags: ["#LaunchFlyerAI", "#PromoPack", "#LaunchDay", "#SmallBusiness"],
        designSuggestions: [
            "Dark glass background with electric mint highlights.",
            "Oversized headline with clear date and CTA stack.",
            "Consistent layout across story, square, banner, and print."
        ],
        assets: CampaignAssetType.allCases.map {
            CampaignPackAsset(
                type: $0,
                title: $0.rawValue,
                headline: "Launch anything in minutes.",
                subtitle: "One idea. Complete campaign.",
                cta: "Create the pack",
                style: .electric,
                exportSizes: ["1080x1080", "PDF"]
            )
        }
    )
}
