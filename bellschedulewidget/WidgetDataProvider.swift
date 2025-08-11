import Foundation

// MARK: - Widget Data Models

struct WidgetData: Codable {
    let currentPeriodName: String?
    let currentPeriodEndTime: Date?
    let currentPeriodTeacher: String?
    let currentPeriodRoom: String?
    let nextPeriodName: String?
    let nextPeriodStartTime: Date?
    let nextPeriodTeacher: String?
    let nextPeriodRoom: String?
    let scheduleStatus: String
    let lastUpdated: Date
    let timeRemaining: TimeInterval?
    let progress: Double?
    
    init(
        currentPeriodName: String? = nil,
        currentPeriodEndTime: Date? = nil,
        currentPeriodTeacher: String? = nil,
        currentPeriodRoom: String? = nil,
        nextPeriodName: String? = nil,
        nextPeriodStartTime: Date? = nil,
        nextPeriodTeacher: String? = nil,
        nextPeriodRoom: String? = nil,
        scheduleStatus: String,
        timeRemaining: TimeInterval? = nil,
        progress: Double? = nil
    ) {
        self.currentPeriodName = currentPeriodName
        self.currentPeriodEndTime = currentPeriodEndTime
        self.currentPeriodTeacher = currentPeriodTeacher
        self.currentPeriodRoom = currentPeriodRoom
        self.nextPeriodName = nextPeriodName
        self.nextPeriodStartTime = nextPeriodStartTime
        self.nextPeriodTeacher = nextPeriodTeacher
        self.nextPeriodRoom = nextPeriodRoom
        self.scheduleStatus = scheduleStatus
        self.lastUpdated = Date()
        self.timeRemaining = timeRemaining
        self.progress = progress
    }
}

// MARK: - Widget Data Provider

class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private let userDefaults: UserDefaults
    private let appGroupIdentifier = "group.club.ehsprogramming.ehsbellschedule"
    
    private init() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            self.userDefaults = sharedDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }
    
    func getWidgetData() -> WidgetData {
        // Try to load from shared UserDefaults first
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            if let data = sharedDefaults.data(forKey: "widgetData"),
               let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
                return widgetData
            }
        }
        
        // Fall back to local UserDefaults
        if let data = userDefaults.data(forKey: "widgetData"),
           let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
            return widgetData
        }
        
        // Return default data
        return WidgetData(scheduleStatus: "No Data")
    }
    
    func saveWidgetData(_ data: WidgetData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: "widgetData")
        } catch {
            print("Failed to save widget data: \(error)")
        }
    }
}

// MARK: - Widget Time Formatter

class WidgetTimeFormatter {
    static let shared = WidgetTimeFormatter()
    
    private let formatter12Hour: DateFormatter
    private let formatter24Hour: DateFormatter
    private let countdownFormatter: DateComponentsFormatter
    
    private init() {
        formatter12Hour = DateFormatter()
        formatter12Hour.dateFormat = "h:mm a"
        
        formatter24Hour = DateFormatter()
        formatter24Hour.dateFormat = "HH:mm"
        
        countdownFormatter = DateComponentsFormatter()
        countdownFormatter.allowedUnits = [.hour, .minute, .second]
        countdownFormatter.unitsStyle = .abbreviated
    }
    
    func formatTime(_ date: Date, use24Hour: Bool) -> String {
        if use24Hour {
            return formatter24Hour.string(from: date)
        } else {
            return formatter12Hour.string(from: date)
        }
    }
    
    func formatCountdown(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, timeInterval))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func formatTimeUntil(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
}