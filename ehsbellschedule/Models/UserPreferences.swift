import Foundation

class UserPreferences: ObservableObject {
    @Published var use24HourFormat: Bool {
        didSet {
            UserDefaults.standard.set(use24HourFormat, forKey: "use24HourFormat")
        }
    }
    
    @Published var showPeriod0: Bool {
        didSet {
            UserDefaults.standard.set(showPeriod0, forKey: "showPeriod0")
        }
    }
    
    @Published var showPeriod7: Bool {
        didSet {
            UserDefaults.standard.set(showPeriod7, forKey: "showPeriod7")
        }
    }
    
    @Published var customClassNames: [Int: String] {
        didSet {
            if let data = try? JSONEncoder().encode(customClassNames) {
                UserDefaults.standard.set(data, forKey: "customClassNames")
            }
        }
    }
    
    @Published var notificationMinutesBefore: Int {
        didSet {
            UserDefaults.standard.set(notificationMinutesBefore, forKey: "notificationMinutesBefore")
        }
    }
    
    @Published var enablePassingPeriodNotifications: Bool {
        didSet {
            UserDefaults.standard.set(enablePassingPeriodNotifications, forKey: "enablePassingPeriodNotifications")
        }
    }
    
    @Published var backgroundImageName: String? {
        didSet {
            UserDefaults.standard.set(backgroundImageName, forKey: "backgroundImageName")
        }
    }
    
    init() {
        self.use24HourFormat = UserDefaults.standard.bool(forKey: "use24HourFormat")
        self.showPeriod0 = UserDefaults.standard.object(forKey: "showPeriod0") as? Bool ?? true
        self.showPeriod7 = UserDefaults.standard.object(forKey: "showPeriod7") as? Bool ?? true
        self.notificationMinutesBefore = UserDefaults.standard.object(forKey: "notificationMinutesBefore") as? Int ?? 2
        self.enablePassingPeriodNotifications = UserDefaults.standard.bool(forKey: "enablePassingPeriodNotifications")
        self.backgroundImageName = UserDefaults.standard.string(forKey: "backgroundImageName")
        
        if let data = UserDefaults.standard.data(forKey: "customClassNames"),
           let names = try? JSONDecoder().decode([Int: String].self, from: data) {
            self.customClassNames = names
        } else {
            self.customClassNames = [:]
        }
    }
    
    func getClassName(for period: Period) -> String {
        return customClassNames[period.number] ?? period.defaultName
    }
    
    func setClassName(_ name: String, for periodNumber: Int) {
        customClassNames[periodNumber] = name.isEmpty ? nil : name
    }
    
    func resetToDefaults() {
        use24HourFormat = false
        showPeriod0 = true
        showPeriod7 = true
        customClassNames = [:]
        notificationMinutesBefore = 2
        enablePassingPeriodNotifications = false
        backgroundImageName = nil
    }
}