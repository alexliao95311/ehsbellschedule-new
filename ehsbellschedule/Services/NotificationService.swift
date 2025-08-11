import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var notificationSettings = NotificationSettings.default
    
    private let center = UNUserNotificationCenter.current()
    private let persistence = DataPersistenceService.shared
    
    private init() {
        checkAuthorizationStatus()
        loadSettings()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
                self.persistence.notificationsEnabled = granted
            }
            
            if granted {
                await scheduleNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuth = settings.authorizationStatus == .authorized
                self?.isAuthorized = isAuth
                print("Notification authorization status: \(settings.authorizationStatus.rawValue), isAuthorized: \(isAuth)")
            }
        }
    }
    
    // MARK: - Settings Management
    
    func loadSettings() {
        notificationSettings = persistence.loadNotificationSettings()
    }
    
    func updateSettings(_ settings: NotificationSettings) {
        self.notificationSettings = settings
        persistence.saveNotificationSettings(settings)
        
        Task {
            await scheduleNotifications()
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleNotifications() async {
        guard isAuthorized && notificationSettings.isEnabled else { return }
        
        // Remove all existing notifications
        center.removeAllPendingNotificationRequests()
        
        let calculator = ScheduleCalculator.shared
        let calendar = Calendar.current
        let today = Date()
        
        // Schedule notifications for the next 7 days
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            if calculator.isSchoolDay(date: targetDate) {
                await scheduleNotificationsForDay(targetDate)
            }
        }
    }
    
    private func scheduleNotificationsForDay(_ date: Date) async {
        let calculator = ScheduleCalculator.shared
        let schedule = calculator.getCurrentSchedule(for: date)
        let preferences = UserPreferences()
        
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        for period in filteredPeriods {
            // Schedule class ending notification
            if notificationSettings.minutesBefore > 0 {
                await scheduleClassEndingNotification(for: period, on: date, preferences: preferences)
            }
            
            // Schedule passing period notification if enabled
            if notificationSettings.includePassingPeriods {
                await schedulePassingPeriodNotification(for: period, on: date, preferences: preferences)
            }
        }
    }
    
    private func scheduleClassEndingNotification(for period: Period, on date: Date, preferences: UserPreferences) async {
        let calendar = Calendar.current
        let periodEndDate = calendar.date(bySettingHour: calendar.component(.hour, from: period.endDate),
                                        minute: calendar.component(.minute, from: period.endDate),
                                        second: 0,
                                        of: date) ?? date
        
        guard let notificationDate = calendar.date(byAdding: .minute, 
                                                 value: -notificationSettings.minutesBefore, 
                                                 to: periodEndDate),
              notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        let className = preferences.getClassName(for: period)
        
        content.title = "\(className) ending soon"
        content.body = "\(className) ends in \(notificationSettings.minutesBefore) minute\(notificationSettings.minutesBefore == 1 ? "" : "s")"
        content.sound = .default
        content.categoryIdentifier = Constants.NotificationCategories.classEnding
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "class_ending_\(period.number)_\(calendar.component(.day, from: date))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try? await center.add(request)
    }
    
    private func schedulePassingPeriodNotification(for period: Period, on date: Date, preferences: UserPreferences) async {
        let calendar = Calendar.current
        let periodEndDate = calendar.date(bySettingHour: calendar.component(.hour, from: period.endDate),
                                        minute: calendar.component(.minute, from: period.endDate),
                                        second: 0,
                                        of: date) ?? date
        
        guard periodEndDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Passing Period"
        content.body = "Time to move to your next class"
        content.sound = .default
        content.categoryIdentifier = Constants.NotificationCategories.passingPeriod
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: periodEndDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "passing_period_\(period.number)_\(calendar.component(.day, from: date))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try? await center.add(request)
    }
    
    // MARK: - Test Notifications
    
    func sendTestNotification() async {
        // First ensure we have permission
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus == .authorized else {
            print("Notifications not authorized. Current status: \(settings.authorizationStatus)")
            return
        }
        
        // Remove any existing test notifications
        center.removePendingNotificationRequests(withIdentifiers: ["test_notification"])
        
        let content = UNMutableNotificationContent()
        content.title = "EHS Bell Schedule"
        content.body = "Test notification - Your bell schedule notifications are working correctly! 🔔"
        content.sound = .default
        content.badge = 1
        
        // Set trigger for 2 seconds to ensure it shows up
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            print("Test notification scheduled successfully")
            
            // Update the published authorization status
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            print("Error sending test notification: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await center.deliveredNotifications()
    }
}