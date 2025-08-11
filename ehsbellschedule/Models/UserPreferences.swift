import Foundation

struct ClassInfo: Codable {
    let name: String
    let teacher: String
    let room: String
    
    init(name: String, teacher: String = "", room: String = "") {
        self.name = name
        self.teacher = teacher
        self.room = room
    }
    
    var displayName: String {
        return name.isEmpty ? "Period" : name
    }
    
    var hasDetails: Bool {
        return !teacher.isEmpty || !room.isEmpty
    }
    
    var detailsText: String {
        var details: [String] = []
        
        if !teacher.isEmpty {
            details.append(teacher)
        }
        
        if !room.isEmpty {
            details.append("Room \(room)")
        }
        
        return details.joined(separator: " • ")
    }
    
    var isEmpty: Bool {
        return name.isEmpty && teacher.isEmpty && room.isEmpty
    }
}

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
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
    
    @Published var customClassInfo: [Int: ClassInfo] {
        didSet {
            if let data = try? JSONEncoder().encode(customClassInfo) {
                UserDefaults.standard.set(data, forKey: "customClassInfo")
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
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    private init() {
        self.use24HourFormat = UserDefaults.standard.bool(forKey: "use24HourFormat")
        self.showPeriod0 = UserDefaults.standard.object(forKey: "showPeriod0") as? Bool ?? true
        self.showPeriod7 = UserDefaults.standard.object(forKey: "showPeriod7") as? Bool ?? true
        self.notificationMinutesBefore = UserDefaults.standard.object(forKey: "notificationMinutesBefore") as? Int ?? 2
        self.enablePassingPeriodNotifications = UserDefaults.standard.bool(forKey: "enablePassingPeriodNotifications")
        self.backgroundImageName = UserDefaults.standard.string(forKey: "backgroundImageName")
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if let data = UserDefaults.standard.data(forKey: "customClassNames"),
           let names = try? JSONDecoder().decode([Int: String].self, from: data) {
            self.customClassNames = names
        } else {
            self.customClassNames = [:]
        }
        
        if let data = UserDefaults.standard.data(forKey: "customClassInfo"),
           let classInfo = try? JSONDecoder().decode([Int: ClassInfo].self, from: data) {
            self.customClassInfo = classInfo
        } else {
            self.customClassInfo = [:]
        }
    }
    
    func getClassName(for period: Period) -> String {
        // ACCESS period (99) and LUNCH period (98) should not be customizable
        if period.number == 99 {
            return "ACCESS"
        }
        if period.number == 98 {
            return "Lunch"
        }
        
        // First check new ClassInfo structure
        if let classInfo = customClassInfo[period.number], !classInfo.isEmpty {
            return classInfo.displayName
        }
        // Fall back to old string-based names for backward compatibility
        return customClassNames[period.number] ?? period.defaultName
    }
    
    func getClassInfo(for period: Period) -> ClassInfo {
        // ACCESS period (99) and LUNCH period (98) should not be customizable
        if period.number == 99 {
            return ClassInfo(name: "ACCESS")
        }
        if period.number == 98 {
            return ClassInfo(name: "Lunch")
        }
        
        // First check new ClassInfo structure
        if let classInfo = customClassInfo[period.number] {
            return classInfo
        }
        
        // Fall back to old string-based names for backward compatibility
        if let oldClassName = customClassNames[period.number] {
            return ClassInfo(name: oldClassName)
        }
        
        // Default case
        return ClassInfo(name: period.defaultName)
    }
    
    func setClassInfo(_ info: ClassInfo, for periodNumber: Int) {
        // ACCESS period (99) and LUNCH period (98) should not be customizable
        if periodNumber == 99 || periodNumber == 98 {
            return
        }
        
        if info.isEmpty {
            customClassInfo[periodNumber] = nil
        } else {
            customClassInfo[periodNumber] = info
        }
    }
    
    func setClassName(_ name: String, for periodNumber: Int) {
        // ACCESS period (99) and LUNCH period (98) should not be customizable
        if periodNumber == 99 || periodNumber == 98 {
            return
        }
        customClassNames[periodNumber] = name.isEmpty ? nil : name
    }
    
    func hasAnyCustomClassNames() -> Bool {
        // Check if any custom class info exists and is not empty
        for (_, classInfo) in customClassInfo {
            if !classInfo.isEmpty {
                return true
            }
        }
        
        // Check legacy custom class names for backward compatibility
        for (_, name) in customClassNames {
            if !name.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    func resetToDefaults() {
        use24HourFormat = false
        showPeriod0 = true
        showPeriod7 = true
        customClassNames = [:]
        customClassInfo = [:]
        notificationMinutesBefore = 2
        enablePassingPeriodNotifications = false
        backgroundImageName = nil
        isDarkMode = false
    }
}