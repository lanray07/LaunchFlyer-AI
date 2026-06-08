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
        case .creator: return "£9.99/mo"
        case .business: return "£19.99/mo"
        case .agency: return "£39.99/mo"
        }
    }
}
