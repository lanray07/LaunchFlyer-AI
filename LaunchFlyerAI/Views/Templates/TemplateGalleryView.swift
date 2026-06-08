import SwiftUI

struct TemplateGalleryView: View {
    @EnvironmentObject private var services: AppServices
    @State private var selectedCategory = "All"

    private var categories: [String] {
        ["All"] + services.templateCatalog.categories
    }

    private var templates: [TemplateDescriptor] {
        selectedCategory == "All"
            ? services.templateCatalog.templates
            : services.templateCatalog.templates.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader("Gallery", title: "Premium templates")
                    categoryPicker
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 18) {
                        ForEach(templates) { template in
                            NavigationLink {
                                FlyerDesignerView(document: document(for: template))
                            } label: {
                                TemplateCard(template: template)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Templates")
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedCategory == category ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? Color.launchMint : Color.white.opacity(0.09), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func document(for template: TemplateDescriptor) -> FlyerDesignDocument {
        var document = FlyerDesignDocument.sample
        document.headline = template.title
        document.style = template.style
        return document
    }
}
