import Foundation
import SwiftUI

struct TemplateDescriptor: Identifiable, Hashable {
    var id = UUID()
    var category: String
    var title: String
    var style: VisualStyle
    var premium: Bool
    var isFeatured: Bool

    var gradient: [Color] { style.gradient }
}

struct TemplateCatalog {
    var templates: [TemplateDescriptor]

    static let `default` = TemplateCatalog(templates: [
        .init(category: "Church", title: "Youth Night Glow", style: .electric, premium: true, isFeatured: true),
        .init(category: "Restaurant", title: "Weekend Table Drop", style: .luxury, premium: true, isFeatured: true),
        .init(category: "Beauty salon", title: "Soft Launch Beauty", style: .elegant, premium: true, isFeatured: false),
        .init(category: "Fitness", title: "Bootcamp Pulse", style: .neon, premium: false, isFeatured: true),
        .init(category: "Real estate", title: "Open House Luxe", style: .minimal, premium: true, isFeatured: false),
        .init(category: "Events", title: "Midnight Poster", style: .bold, premium: false, isFeatured: true),
        .init(category: "School", title: "Community Fair", style: .playful, premium: false, isFeatured: false),
        .init(category: "Conference", title: "Keynote Signal", style: .editorial, premium: true, isFeatured: false),
        .init(category: "Ecommerce", title: "Product Drop", style: .electric, premium: true, isFeatured: true),
        .init(category: "Local services", title: "Service Pro", style: .minimal, premium: false, isFeatured: false),
        .init(category: "Concerts", title: "Stage Lights", style: .neon, premium: true, isFeatured: false),
        .init(category: "Weddings", title: "Elegant Invite", style: .elegant, premium: true, isFeatured: false),
        .init(category: "Black Friday", title: "Flash Sale", style: .bold, premium: true, isFeatured: true),
        .init(category: "Grand opening", title: "Opening Night", style: .luxury, premium: false, isFeatured: true)
    ])

    var categories: [String] {
        Array(Set(templates.map(\.category))).sorted()
    }
}

final class TemplateEngine {
    func apply(template: TemplateDescriptor, to document: FlyerDesignDocument) -> FlyerDesignDocument {
        var updated = document
        updated.style = template.style
        updated.layout = template.category == "Real estate" ? .split : .hero
        return updated
    }
}
