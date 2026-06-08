import Foundation

#if canImport(WidgetKit)
import WidgetKit

struct LaunchFlyerWidgetPlan {
    var recentCampaignEnabled = true
    var quickCreateEnabled = true
    var launchCountdownEnabled = true
    var designInspirationEnabled = true
}

struct LaunchFlyerWidgetTimelinePayload: Codable, Hashable {
    var campaignTitle: String
    var launchDate: Date
    var inspirationPrompt: String
}
#endif
