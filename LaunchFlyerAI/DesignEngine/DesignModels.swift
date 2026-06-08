import Foundation
import SwiftUI

struct FlyerDesignDocument: Identifiable, Codable, Equatable {
    var id = UUID()
    var headline: String
    var subtitle: String
    var offer: String
    var eventDetails: String
    var callToAction: String
    var imagePlaceholder: String
    var logoPlaceholder: String
    var qrCodePlaceholder: String
    var contactDetails: String
    var style: VisualStyle
    var layout: FlyerLayout
    var spacing: Double

    static let sample = FlyerDesignDocument(
        headline: "Grand Opening Weekend",
        subtitle: "Launch anything in minutes.",
        offer: "Free gift for the first 50 guests",
        eventDetails: "Saturday, 6 PM • Downtown Studio",
        callToAction: "Book your spot",
        imagePlaceholder: "Hero image",
        logoPlaceholder: "Logo",
        qrCodePlaceholder: "QR",
        contactDetails: "@launchflyer • hello@example.com",
        style: .electric,
        layout: .hero,
        spacing: 18
    )
}

enum FlyerLayout: String, CaseIterable, Identifiable, Codable, Hashable {
    case hero = "Hero"
    case editorial = "Editorial"
    case split = "Split"
    case poster = "Poster"

    var id: String { rawValue }
}

struct BrandStyle: Codable, Equatable {
    var colors: [String]
    var displayFont: String
    var bodyFont: String
    var voice: CopyTone

    static let premiumStarter = BrandStyle(
        colors: ["#60F5C8", "#7C5CFF", "#FF3D81", "#F8D66D"],
        displayFont: "New York",
        bodyFont: "SF Pro",
        voice: .bold
    )
}

struct CampaignPackAsset: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: CampaignAssetType
    var title: String
    var headline: String
    var subtitle: String
    var cta: String
    var style: VisualStyle
    var exportSizes: [String]
}
