import Foundation
import SwiftUI

enum UserType: String, CaseIterable, Identifiable, Codable, Hashable {
    case businessOwner = "Business owner"
    case churchOrganizer = "Church/event organizer"
    case creator = "Creator"
    case marketer = "Marketer"
    case agency = "Agency"
    case freelancer = "Freelancer"
    case restaurantOwner = "Restaurant owner"
    case fitnessCoach = "Fitness coach"
    case realEstateAgent = "Real estate agent"

    var id: String { rawValue }
}

enum MainGoal: String, CaseIterable, Identifiable, Codable, Hashable {
    case promoteEvent = "Promote an event"
    case launchProduct = "Launch a product"
    case advertiseService = "Advertise a service"
    case announceSale = "Announce a sale"
    case createSocialContent = "Create social content"
    case buildCampaignPack = "Build campaign pack"

    var id: String { rawValue }
}

enum CampaignType: String, CaseIterable, Identifiable, Codable, Hashable {
    case event = "Event"
    case productLaunch = "Product launch"
    case service = "Service"
    case sale = "Sale"
    case church = "Church"
    case restaurant = "Restaurant"
    case fitness = "Fitness"
    case realEstate = "Real estate"
    case beauty = "Beauty"
    case school = "School"
    case localCampaign = "Local campaign"

    var id: String { rawValue }
}

enum CampaignAssetType: String, CaseIterable, Identifiable, Codable, Hashable {
    case flyer = "Flyer"
    case poster = "Poster"
    case instagramPost = "Instagram post"
    case instagramStory = "Instagram story"
    case reelCover = "TikTok/Reel cover"
    case facebookBanner = "Facebook banner"
    case whatsappFlyer = "WhatsApp flyer"
    case emailBanner = "Email banner"
    case caption = "Promotional caption"
    case hashtags = "Hashtag set"

    var id: String { rawValue }

    var aspectRatio: CGFloat {
        switch self {
        case .instagramStory:
            return 9.0 / 16.0
        case .facebookBanner, .emailBanner:
            return 1.91
        case .poster, .flyer:
            return 0.77
        default:
            return 1
        }
    }
}

enum VisualStyle: String, CaseIterable, Identifiable, Codable, Hashable {
    case luxury = "Luxury"
    case electric = "Electric"
    case elegant = "Elegant"
    case bold = "Bold"
    case playful = "Playful"
    case minimal = "Minimal"
    case editorial = "Editorial"
    case neon = "Neon"

    var id: String { rawValue }

    var gradient: [Color] {
        switch self {
        case .luxury:
            return [.black, .launchGold, .launchBerry]
        case .electric:
            return [.launchElectric, .launchMint, .launchBerry]
        case .elegant:
            return [.launchInk, .launchSilver, .launchGold]
        case .bold:
            return [.launchBerry, .launchOrange, .launchGold]
        case .playful:
            return [.launchMint, .launchElectric, .launchOrange]
        case .minimal:
            return [.launchInk, .launchGraphite, .launchSilver]
        case .editorial:
            return [.launchGraphite, .launchGold, .launchRose]
        case .neon:
            return [.black, .launchElectric, .launchMint]
        }
    }
}

enum CopyTone: String, CaseIterable, Identifiable, Codable, Hashable {
    case luxury = "Luxury"
    case friendly = "Friendly"
    case bold = "Bold"
    case professional = "Professional"
    case fun = "Fun"
    case urgent = "Urgent"
    case elegant = "Elegant"

    var id: String { rawValue }
}

enum ExportFormat: String, CaseIterable, Identifiable, Codable, Hashable {
    case png = "PNG"
    case jpg = "JPG"
    case pdf = "PDF"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable, Hashable {
    case free = "Free"
    case creator = "Creator"
    case business = "Business"
    case agency = "Agency"

    var id: String { rawValue }

    var price: String {
        switch self {
        case .free: return "Free"
        case .creator: return "GBP 9.99/mo"
        case .business: return "GBP 19.99/mo"
        case .agency: return "GBP 39.99/mo"
        }
    }

    var includedFeatures: [String] {
        switch self {
        case .free:
            return ["3 campaigns/month", "Basic templates", "Limited exports", "LaunchFlyer AI watermark"]
        case .creator:
            return ["Unlimited campaigns", "Premium templates", "No watermark", "AI copywriter", "Social media packs"]
        case .business:
            return ["Everything in Creator", "Brand kit", "Batch exports", "Event packs", "Print-ready exports"]
        case .agency:
            return ["Everything in Business", "Multiple brand kits", "White-label exports", "Client folders", "Campaign automation"]
        }
    }
}

enum SubscriptionSKU: String, CaseIterable, Identifiable, Codable, Hashable {
    case creatorMonthly = "launchflyer.creator.monthly"
    case creatorYearly = "launchflyer.creator.yearly"
    case businessMonthly = "launchflyer.business.monthly"
    case agencyMonthly = "launchflyer.agency.monthly"

    var id: String { rawValue }

    var plan: SubscriptionPlan {
        switch self {
        case .creatorMonthly, .creatorYearly:
            return .creator
        case .businessMonthly:
            return .business
        case .agencyMonthly:
            return .agency
        }
    }

    var displayName: String {
        switch self {
        case .creatorMonthly: return "Creator Monthly"
        case .creatorYearly: return "Creator Yearly"
        case .businessMonthly: return "Business Monthly"
        case .agencyMonthly: return "Agency Monthly"
        }
    }

    var fallbackPrice: String {
        switch self {
        case .creatorMonthly: return "GBP 9.99"
        case .creatorYearly: return "GBP 79.99"
        case .businessMonthly: return "GBP 19.99"
        case .agencyMonthly: return "GBP 39.99"
        }
    }

    var cadence: String {
        switch self {
        case .creatorYearly:
            return "per year"
        default:
            return "per month"
        }
    }

    var badge: String? {
        switch self {
        case .creatorYearly:
            return "Best value"
        case .businessMonthly:
            return "For teams"
        case .agencyMonthly:
            return "Scale"
        case .creatorMonthly:
            return nil
        }
    }

    var benefits: [String] {
        switch self {
        case .creatorMonthly:
            return ["Unlimited campaigns", "Premium templates", "No watermark", "AI copywriter", "Social media packs"]
        case .creatorYearly:
            return ["All Creator features", "Two months equivalent savings", "Priority template drops", "No watermark"]
        case .businessMonthly:
            return ["Brand kit", "Batch exports", "Event packs", "Advanced templates", "Print-ready exports"]
        case .agencyMonthly:
            return ["Multiple brand kits", "White-label exports", "Client folders", "Campaign pack automation", "Agency-ready workflows"]
        }
    }
}
