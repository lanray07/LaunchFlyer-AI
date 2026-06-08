import Foundation

struct LaunchFlyerWatchReminder: Identifiable, Codable, Hashable {
    var id = UUID()
    var campaignTitle: String
    var deadline: Date
    var alertType: AlertType

    enum AlertType: String, Codable, Hashable {
        case launchReminder
        case campaignDeadline
        case exportNotification
    }
}

struct LaunchFlyerWatchBridge {
    func pendingReminders() -> [LaunchFlyerWatchReminder] {
        [
            LaunchFlyerWatchReminder(
                campaignTitle: "Weekend Launch",
                deadline: .now.addingTimeInterval(86_400),
                alertType: .launchReminder
            )
        ]
    }
}
