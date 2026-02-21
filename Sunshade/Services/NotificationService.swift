import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private let reapplyIdentifier = "sunscreen-reapply-reminder"

    private init() {}

    /// Requests authorization for local notifications (.alert, .sound, .badge).
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                #if DEBUG
                print("Notification permission error: \(error.localizedDescription)")
                #endif
            }
            #if DEBUG
            print("Notification permission granted: \(granted)")
            #endif
        }
    }

    /// Schedules a repeating local notification to remind the user to reapply sunscreen.
    /// - Parameter interval: Time interval between reminders in seconds. Defaults to 7200 (2 hours).
    func scheduleReapplicationReminder(interval: TimeInterval = 7200) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Reapply Sunscreen"
        content.body = "You've been outside for 2 hours. Reapply SPF 30+ for continued protection."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: reapplyIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("Failed to schedule reapply reminder: \(error.localizedDescription)")
            } else {
                print("Reapply reminder scheduled every \(Int(interval / 60)) minutes")
            }
            #endif
        }
    }

    /// Cancels all pending notification requests.
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        #if DEBUG
        print("All pending notification reminders cancelled")
        #endif
    }
}
