import Combine
import Foundation

final class CampaignPromptViewModel: ObservableObject {
    @Published var campaignType: CampaignType = .restaurant
    @Published var businessName = "Glow & Grind Coffee"
    @Published var dateTime = "Friday, 7:00 PM"
    @Published var location = "Downtown High Street"
    @Published var offer = "Free pastry with every launch-night coffee flight"
    @Published var targetAudience = "Local professionals, students, creators, and weekend brunch customers"
    @Published var visualStyle: VisualStyle = .electric
    @Published var callToAction = "Reserve your tasting slot"
    @Published var campaignGoal = "Drive launch-night visits and collect early loyal customers."
    @Published var deliverables = "Flyer, poster, Instagram post, Instagram story, Reel cover, Facebook banner, WhatsApp flyer, email banner, captions, and hashtags."
    @Published var brandNotes = "Premium dark background, electric mint highlights, high-energy launch tone, modern local-business polish."
    @Published var contactDetails = "@glowgrindcoffee | hello@glowgrind.example | 020 0000 0000"
    @Published var brief = "Create a complete launch campaign for a premium coffee bar opening weekend with strong urgency, polished visuals, and social-ready copy."
    @Published var generatedCampaign: GeneratedCampaign?
    @Published var flyerDesign: FlyerDesignDocument?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var request: CampaignRequest {
        CampaignRequest(
            module: "campaign-prompt",
            campaignType: campaignType,
            businessName: businessName,
            campaignBrief: compiledBrief,
            voiceTranscript: "",
            dateTime: dateTime,
            location: location,
            offer: offer,
            style: visualStyle,
            targetAudience: targetAudience,
            callToAction: callToAction
        )
    }

    var compiledBrief: String {
        [
            "Brief: \(brief)",
            "Goal: \(campaignGoal)",
            "Deliverables: \(deliverables)",
            "Brand direction: \(brandNotes)",
            "Contact details: \(contactDetails)"
        ].joined(separator: "\n")
    }

    @MainActor
    func generate(using services: AppServices) async {
        isLoading = true
        errorMessage = nil
        generatedCampaign = nil
        flyerDesign = nil
        do {
            async let campaign = services.campaignGenerationService.generate(request)
            async let design = services.flyerDesignService.generateDesign(request)
            generatedCampaign = try await campaign
            flyerDesign = try await design
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func applyPreset(_ preset: CampaignFormPreset) {
        campaignType = preset.campaignType
        businessName = preset.businessName
        dateTime = preset.dateTime
        location = preset.location
        offer = preset.offer
        targetAudience = preset.targetAudience
        visualStyle = preset.visualStyle
        callToAction = preset.callToAction
        campaignGoal = preset.campaignGoal
        deliverables = preset.deliverables
        brandNotes = preset.brandNotes
        contactDetails = preset.contactDetails
        brief = preset.brief
    }
}

struct CampaignFormPreset: Identifiable, Hashable {
    var id: String { title }
    var title: String
    var icon: String
    var campaignType: CampaignType
    var businessName: String
    var dateTime: String
    var location: String
    var offer: String
    var targetAudience: String
    var visualStyle: VisualStyle
    var callToAction: String
    var campaignGoal: String
    var deliverables: String
    var brandNotes: String
    var contactDetails: String
    var brief: String

    static let samples: [CampaignFormPreset] = [
        restaurantLaunch,
        churchEvent,
        fitnessBootcamp,
        realEstateOpenHouse
    ]

    static let restaurantLaunch = CampaignFormPreset(
        title: "Restaurant",
        icon: "fork.knife",
        campaignType: .restaurant,
        businessName: "Glow & Grind Coffee",
        dateTime: "Friday, 7:00 PM",
        location: "Downtown High Street",
        offer: "Free pastry with every launch-night coffee flight",
        targetAudience: "Local professionals, students, creators, and weekend brunch customers",
        visualStyle: .electric,
        callToAction: "Reserve your tasting slot",
        campaignGoal: "Drive launch-night visits and collect early loyal customers.",
        deliverables: "Flyer, poster, Instagram post, Instagram story, Reel cover, Facebook banner, WhatsApp flyer, email banner, captions, and hashtags.",
        brandNotes: "Premium dark background, electric mint highlights, high-energy launch tone, modern local-business polish.",
        contactDetails: "@glowgrindcoffee | hello@glowgrind.example | 020 0000 0000",
        brief: "Create a complete launch campaign for a premium coffee bar opening weekend with strong urgency, polished visuals, and social-ready copy."
    )

    static let churchEvent = CampaignFormPreset(
        title: "Church Event",
        icon: "sparkles",
        campaignType: .church,
        businessName: "City Hope Youth Night",
        dateTime: "Next Friday, 6:30 PM",
        location: "City Hope Church Hall",
        offer: "Free entry, live music, food, and games",
        targetAudience: "Teenagers, parents, youth leaders, and local families",
        visualStyle: .bold,
        callToAction: "Invite a friend",
        campaignGoal: "Increase youth attendance and make the event feel welcoming, safe, and exciting.",
        deliverables: "Event flyer, RSVP graphic, countdown story, reminder post, WhatsApp flyer, captions, and hashtags.",
        brandNotes: "Bright, hopeful, energetic, modern church event design with clear date, time, and invitation.",
        contactDetails: "@cityhopeyouth | youth@cityhope.example | 020 1111 1111",
        brief: "Create a youth event campaign that feels vibrant, faith-friendly, community-led, and easy to share."
    )

    static let fitnessBootcamp = CampaignFormPreset(
        title: "Fitness",
        icon: "figure.strengthtraining.traditional",
        campaignType: .fitness,
        businessName: "Pulse 45 Bootcamp",
        dateTime: "Monday, 6:00 AM",
        location: "Riverside Park",
        offer: "First class free for new members",
        targetAudience: "Busy professionals, beginners, and fitness restart customers",
        visualStyle: .neon,
        callToAction: "Claim your free class",
        campaignGoal: "Generate bookings for a new outdoor fitness class and make the offer feel urgent.",
        deliverables: "Flyer, Instagram post, story, Reel cover, WhatsApp status, captions, hashtags, and SMS copy.",
        brandNotes: "High contrast, athletic, bold typography, neon movement energy, premium coaching feel.",
        contactDetails: "@pulse45fit | join@pulse45.example | 020 2222 2222",
        brief: "Create a punchy promotional pack for a new fitness bootcamp that motivates people to book fast."
    )

    static let realEstateOpenHouse = CampaignFormPreset(
        title: "Real Estate",
        icon: "house.fill",
        campaignType: .realEstate,
        businessName: "23 Alder House Open Viewing",
        dateTime: "Saturday, 11:00 AM - 2:00 PM",
        location: "23 Alder House, Westbrook",
        offer: "Newly listed 3-bed home with garden studio",
        targetAudience: "First-time buyers, young families, and relocating professionals",
        visualStyle: .minimal,
        callToAction: "Book a private viewing",
        campaignGoal: "Drive open house attendance and collect qualified buyer enquiries.",
        deliverables: "Open house flyer, Facebook banner, Instagram post, story, email banner, listing caption, and hashtags.",
        brandNotes: "Premium editorial property style, clean typography, restrained palette, clear viewing details.",
        contactDetails: "Alder Realty | viewings@alder.example | 020 3333 3333",
        brief: "Create a polished real estate open house campaign that highlights lifestyle, location, and urgency."
    )
}
