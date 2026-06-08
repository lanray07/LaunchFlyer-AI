import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var userType: String
    var mainGoal: String
    var createdAt: Date

    init(id: UUID = UUID(), userType: String, mainGoal: String, createdAt: Date = .now) {
        self.id = id
        self.userType = userType
        self.mainGoal = mainGoal
        self.createdAt = createdAt
    }
}

@Model
final class Campaign {
    @Attribute(.unique) var id: UUID
    var title: String
    var campaignType: String
    var brief: String
    var style: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        campaignType: String,
        brief: String,
        style: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.campaignType = campaignType
        self.brief = brief
        self.style = style
        self.createdAt = createdAt
    }
}

@Model
final class CampaignAsset {
    @Attribute(.unique) var id: UUID
    var campaignId: UUID
    var assetType: String
    var designData: String
    var exportFormat: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        campaignId: UUID,
        assetType: String,
        designData: String,
        exportFormat: String = ExportFormat.png.rawValue,
        createdAt: Date = .now
    ) {
        self.id = id
        self.campaignId = campaignId
        self.assetType = assetType
        self.designData = designData
        self.exportFormat = exportFormat
        self.createdAt = createdAt
    }
}

@Model
final class Template {
    @Attribute(.unique) var id: UUID
    var category: String
    var title: String
    var style: String
    var premium: Bool

    init(id: UUID = UUID(), category: String, title: String, style: String, premium: Bool = false) {
        self.id = id
        self.category = category
        self.title = title
        self.style = style
        self.premium = premium
    }
}

@Model
final class BrandKit {
    @Attribute(.unique) var id: UUID
    var brandName: String
    var colors: String
    var logoPlaceholder: String
    var fontsPlaceholder: String
    var contactDetails: String
    var socialHandles: String
    var qrCodePlaceholder: String

    init(
        id: UUID = UUID(),
        brandName: String,
        colors: String,
        logoPlaceholder: String = "Logo placeholder",
        fontsPlaceholder: String = "Display / Body font placeholders",
        contactDetails: String = "",
        socialHandles: String = "",
        qrCodePlaceholder: String = "QR code placeholder"
    ) {
        self.id = id
        self.brandName = brandName
        self.colors = colors
        self.logoPlaceholder = logoPlaceholder
        self.fontsPlaceholder = fontsPlaceholder
        self.contactDetails = contactDetails
        self.socialHandles = socialHandles
        self.qrCodePlaceholder = qrCodePlaceholder
    }

    var colorTokens: [String] {
        colors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

@Model
final class VoiceTranscript {
    @Attribute(.unique) var id: UUID
    var transcript: String
    var generatedBrief: String
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, generatedBrief: String, createdAt: Date = .now) {
        self.id = id
        self.transcript = transcript
        self.generatedBrief = generatedBrief
        self.createdAt = createdAt
    }
}

@Model
final class ExportRecord {
    @Attribute(.unique) var id: UUID
    var campaignId: UUID
    var format: String
    var size: String
    var createdAt: Date

    init(id: UUID = UUID(), campaignId: UUID, format: String, size: String, createdAt: Date = .now) {
        self.id = id
        self.campaignId = campaignId
        self.format = format
        self.size = size
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool

    init(id: UUID = UUID(), plan: String = SubscriptionPlan.free.rawValue, isActive: Bool = false) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
    }
}
