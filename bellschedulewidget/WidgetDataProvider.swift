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
        print("🔍 Widget requesting data...")
        
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            print("✅ Shared UserDefaults available")
            
            // Force refresh the shared UserDefaults
            sharedDefaults.synchronize()
            
            if let data = sharedDefaults.data(forKey: "widgetData") {
                print("📦 Found data in shared UserDefaults, size: \(data.count) bytes")
                if let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
                    print("✅ Successfully decoded widget data:")
                    print("   Status: \(widgetData.scheduleStatus)")
                    print("   Current period: \(widgetData.currentPeriodName ?? "nil")")
                    print("   Teacher: \(widgetData.currentPeriodTeacher ?? "nil")")
                    print("   Room: \(widgetData.currentPeriodRoom ?? "nil")")
                    print("   Time remaining: \(widgetData.timeRemaining ?? 0)")
                    print("   Last updated: \(widgetData.lastUpdated)")
                    
                    // Check if data is stale (older than 30 seconds)
                    let timeSinceUpdate = Date().timeIntervalSince(widgetData.lastUpdated)
                    if timeSinceUpdate > 30 {
                        print("⚠️ Data is stale! Last updated \(Int(timeSinceUpdate)) seconds ago")
                    } else {
                        print("✅ Data is fresh! Updated \(Int(timeSinceUpdate)) seconds ago")
                    }
                    
                    return widgetData
                } else {
                    print("❌ Failed to decode widget data from shared UserDefaults")
                }
            } else {
                print("❌ No data found in shared UserDefaults")
            }
        } else {
            print("❌ Shared UserDefaults not available")
        }
        
        // Fall back to local UserDefaults
        print("🔄 Falling back to local UserDefaults...")
        if let data = userDefaults.data(forKey: "widgetData") {
            print("📦 Found data in local UserDefaults, size: \(data.count) bytes")
            if let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
                print("✅ Successfully decoded widget data from local UserDefaults")
                return widgetData
            } else {
                print("❌ Failed to decode widget data from local UserDefaults")
            }
        } else {
            print("❌ No data found in local UserDefaults either")
        }
        
        print("⚠️ Returning default 'No Data' widget data")
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