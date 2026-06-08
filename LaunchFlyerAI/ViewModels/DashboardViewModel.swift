import Combine
import Foundation

final class DashboardViewModel: ObservableObject {
    @Published var aiSuggestions = [
        "Turn your next offer into a full social pack.",
        "Refresh your brand kit before exporting print assets.",
        "Try a voice brief for your next event flyer."
    ]

    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "Morning launch desk" }
        if hour < 18 { return "Campaign studio" }
        return "Evening launch room"
    }
}
