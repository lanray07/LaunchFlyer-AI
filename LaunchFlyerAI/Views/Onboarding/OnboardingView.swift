import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedUserType: UserType = .businessOwner
    @State private var selectedGoal: MainGoal = .buildCampaignPack
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("LaunchFlyer AI")
                            .font(.system(size: 46, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Launch anything in minutes.")
                            .font(.title2.bold())
                            .foregroundStyle(.launchMint)
                        Text("One idea. Complete campaign.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.68))
                    }
                    .padding(.top, 34)

                    SelectionGrid(
                        title: "What best describes you?",
                        options: UserType.allCases,
                        selection: $selectedUserType
                    )

                    SelectionGrid(
                        title: "What do you want to do first?",
                        options: MainGoal.allCases,
                        selection: $selectedGoal
                    )

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Personalized workspace", systemImage: "sparkles")
                            Label("Recommended templates", systemImage: "rectangle.stack.fill")
                            Label("Starter brand style", systemImage: "paintpalette.fill")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                    }

                    Button {
                        saveProfile()
                        onComplete()
                    } label: {
                        Label("Enter Campaign Studio", systemImage: "arrow.right")
                    }
                    .buttonStyle(PremiumButtonStyle())
                }
                .padding()
            }
        }
    }

    private func saveProfile() {
        let profile = UserProfile(userType: selectedUserType.rawValue, mainGoal: selectedGoal.rawValue)
        let brandKit = BrandKit(
            brandName: "\(selectedUserType.rawValue) Kit",
            colors: BrandStyle.premiumStarter.colors.joined(separator: ","),
            contactDetails: "Website • Instagram • Phone"
        )
        modelContext.insert(profile)
        modelContext.insert(brandKit)
        try? modelContext.save()
    }
}

private struct SelectionGrid<Option: Identifiable & RawRepresentable>: View where Option.RawValue == String, Option.ID == String {
    var title: String
    var options: [Option]
    @Binding var selection: Option

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(option.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selection.id == option.id ? .black : .white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .padding(.horizontal, 12)
                            .background(
                                selection.id == option.id ? Color.launchMint : Color.white.opacity(0.09),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
