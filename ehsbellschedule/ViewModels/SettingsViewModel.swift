import Foundation
import Combine
import UIKit

class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences
    @Published var notificationService: NotificationService
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.preferences = UserPreferences.shared
        self.notificationService = NotificationService.shared
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Update notification schedules when relevant preferences change
        preferences.$notificationMinutesBefore
            .combineLatest(preferences.$enablePassingPeriodNotifications)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.updateNotificationSchedule()
            }
            .store(in: &cancellables)
        
        // Update widget data when preferences change
        preferences.$customClassNames
            .combineLatest(preferences.$showPeriod0, preferences.$showPeriod7)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.updateWidgetData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Notification Management
    
    func requestNotificationPermission() async -> Bool {
        return await notificationService.requestAuthorization()
    }
    
    func sendTestNotification() async {
        await notificationService.sendTestNotification()
    }
    
    private func updateNotificationSchedule() {
        guard notificationService.isAuthorized else { return }
        
        let settings = NotificationSettings(
            isEnabled: true,
            minutesBefore: preferences.notificationMinutesBefore,
            includePassingPeriods: preferences.enablePassingPeriodNotifications
        )
        
        notificationService.updateSettings(settings)
    }
    
    // MARK: - Widget Data Management
    
    private func updateWidgetData() {
        let calculator = ScheduleCalculator.shared
        let status = calculator.getScheduleStatus()
        
        let widgetData = createWidgetData(from: status)
        DataPersistenceService.shared.saveWidgetData(widgetData)
    }
    
    private func createWidgetData(from status: ScheduleStatus) -> WidgetData {
        switch status {
        case .inClass(let period, let timeRemaining, let progress):
            let className = preferences.getClassName(for: period)
            return WidgetData(
                currentPeriodName: className,
                currentPeriodEndTime: period.endDate,
                scheduleStatus: "In Class",
                timeRemaining: timeRemaining,
                progress: progress
            )
            
        case .passingPeriod(let nextPeriod, let timeUntilNext):
            let nextClassName = preferences.getClassName(for: nextPeriod)
            return WidgetData(
                nextPeriodName: nextClassName,
                nextPeriodStartTime: nextPeriod.startDate,
                scheduleStatus: "Passing Period",
                timeRemaining: timeUntilNext
            )
            
        case .beforeSchool(let nextPeriod, let timeUntilNext):
            let nextClassName = preferences.getClassName(for: nextPeriod)
            return WidgetData(
                nextPeriodName: nextClassName,
                nextPeriodStartTime: nextPeriod.startDate,
                scheduleStatus: "Before School",
                timeRemaining: timeUntilNext
            )
            
        case .afterSchool:
            return WidgetData(scheduleStatus: "After School")
            
        case .noSchool:
            return WidgetData(scheduleStatus: "No School")
        }
    }
    
    // MARK: - Settings Management
    
    func resetAllSettings() {
        preferences.resetToDefaults()
        notificationService.clearAllNotifications()
        updateWidgetData()
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func exportSettings() -> String {
        let settings: [String: Any] = [
            "showPeriod0": preferences.showPeriod0,
            "showPeriod7": preferences.showPeriod7,
            "customClassNames": preferences.customClassNames,
            "customClassInfo": preferences.customClassInfo,
            "notificationMinutesBefore": preferences.notificationMinutesBefore,
            "enablePassingPeriodNotifications": preferences.enablePassingPeriodNotifications,
            "backgroundImageName": preferences.backgroundImageName ?? "None"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settings, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "Failed to export settings"
        } catch {
            return "Failed to export settings: \(error.localizedDescription)"
        }
    }
    
    func importSettings(_ jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        
        do {
            let settings = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            if let showPeriod0 = settings?["showPeriod0"] as? Bool {
                preferences.showPeriod0 = showPeriod0
            }
            if let showPeriod7 = settings?["showPeriod7"] as? Bool {
                preferences.showPeriod7 = showPeriod7
            }
            if let customClassNames = settings?["customClassNames"] as? [Int: String] {
                preferences.customClassNames = customClassNames
            }
            if let customClassInfo = settings?["customClassInfo"] as? [Int: ClassInfo] {
                preferences.customClassInfo = customClassInfo
            }
            if let notificationMinutesBefore = settings?["notificationMinutesBefore"] as? Int {
                preferences.notificationMinutesBefore = notificationMinutesBefore
            }
            if let enablePassingPeriodNotifications = settings?["enablePassingPeriodNotifications"] as? Bool {
                preferences.enablePassingPeriodNotifications = enablePassingPeriodNotifications
            }
            if let backgroundImageName = settings?["backgroundImageName"] as? String, backgroundImageName != "None" {
                preferences.backgroundImageName = backgroundImageName
            } else {
                preferences.backgroundImageName = nil
            }
        } catch {
            print("Failed to import settings: \(error.localizedDescription)")
        }
    }
}