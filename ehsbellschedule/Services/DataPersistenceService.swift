import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let userDefaults: UserDefaults
    private let sharedUserDefaults: UserDefaults?
    
    private init() {
        self.userDefaults = UserDefaults.standard
        self.sharedUserDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
    }
    
    // MARK: - Generic Storage Methods
    
    func save<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to save object for key \(key): \(error)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to load object for key \(key): \(error)")
            return nil
        }
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Specific Data Methods
    
    func saveCustomClassNames(_ names: [Int: String]) {
        save(names, forKey: Constants.UserDefaultsKeys.customClassNames)
    }
    
    func loadCustomClassNames() -> [Int: String] {
        return load([Int: String].self, forKey: Constants.UserDefaultsKeys.customClassNames) ?? [:]
    }
    
    func saveNotificationSettings(_ settings: NotificationSettings) {
        save(settings, forKey: "notificationSettings")
    }
    
    func loadNotificationSettings() -> NotificationSettings {
        return load(NotificationSettings.self, forKey: "notificationSettings") ?? NotificationSettings.default
    }
    
    // MARK: - User Preferences
    
    var use24HourFormat: Bool {
        get { userDefaults.bool(forKey: Constants.UserDefaultsKeys.use24HourFormat) }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.use24HourFormat) }
    }
    
    var showPeriod0: Bool {
        get { userDefaults.object(forKey: Constants.UserDefaultsKeys.showPeriod0) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.showPeriod0) }
    }
    
    var showPeriod7: Bool {
        get { userDefaults.object(forKey: Constants.UserDefaultsKeys.showPeriod7) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.showPeriod7) }
    }
    
    var notificationMinutesBefore: Int {
        get { userDefaults.object(forKey: Constants.UserDefaultsKeys.notificationMinutesBefore) as? Int ?? Constants.Timing.defaultNotificationMinutes }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.notificationMinutesBefore) }
    }
    
    var enablePassingPeriodNotifications: Bool {
        get { userDefaults.bool(forKey: Constants.UserDefaultsKeys.enablePassingPeriodNotifications) }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.enablePassingPeriodNotifications) }
    }
    
    var backgroundImageName: String? {
        get { userDefaults.string(forKey: Constants.UserDefaultsKeys.backgroundImageName) }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.backgroundImageName) }
    }
    
    var notificationsEnabled: Bool {
        get { userDefaults.object(forKey: Constants.UserDefaultsKeys.notificationsEnabled) as? Bool ?? false }
        set { userDefaults.set(newValue, forKey: Constants.UserDefaultsKeys.notificationsEnabled) }
    }
    
    // MARK: - Widget Data Sharing
    
    func saveWidgetData(_ data: WidgetData) {
        // Save to shared UserDefaults for widget access
        if let sharedDefaults = sharedUserDefaults {
            do {
                let encoded = try JSONEncoder().encode(data)
                sharedDefaults.set(encoded, forKey: "widgetData")
                sharedDefaults.synchronize()
            } catch {
                print("Failed to save widget data to shared UserDefaults: \(error)")
            }
        }
        
        // Also save to local UserDefaults as backup
        save(data, forKey: "widgetData")
    }
    
    func loadWidgetData() -> WidgetData? {
        // Try to load from shared UserDefaults first
        if let sharedDefaults = sharedUserDefaults,
           let data = sharedDefaults.data(forKey: "widgetData"),
           let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) {
            return widgetData
        }
        
        // Fall back to local UserDefaults
        return load(WidgetData.self, forKey: "widgetData")
    }
    
    // MARK: - Reset Methods
    
    func resetUserPreferences() {
        let keysToRemove = [
            Constants.UserDefaultsKeys.use24HourFormat,
            Constants.UserDefaultsKeys.showPeriod0,
            Constants.UserDefaultsKeys.showPeriod7,
            Constants.UserDefaultsKeys.customClassNames,
            Constants.UserDefaultsKeys.notificationMinutesBefore,
            Constants.UserDefaultsKeys.enablePassingPeriodNotifications,
            Constants.UserDefaultsKeys.backgroundImageName,
            Constants.UserDefaultsKeys.notificationsEnabled
        ]
        
        keysToRemove.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func synchronize() {
        userDefaults.synchronize()
    }
}

// MARK: - Widget Data Model

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