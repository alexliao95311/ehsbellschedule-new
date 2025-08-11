import Foundation

struct Period: Identifiable, Codable, Equatable {
    let id = UUID()
    let number: Int
    let startTime: TimeInterval
    let endTime: TimeInterval
    let defaultName: String
    
    var duration: TimeInterval {
        endTime - startTime
    }
    
    var startDate: Date {
        Date(timeIntervalSinceReferenceDate: startTime)
    }
    
    var endDate: Date {
        Date(timeIntervalSinceReferenceDate: endTime)
    }
    
    init(number: Int, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, defaultName: String) {
        self.number = number
        self.defaultName = defaultName
        
        let calendar = Calendar.current
        let today = Date()
        
        let startComponents = DateComponents(hour: startHour, minute: startMinute)
        let endComponents = DateComponents(hour: endHour, minute: endMinute)
        
        let startDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: today) ?? today
        let endDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: today) ?? today
        
        self.startTime = startDate.timeIntervalSinceReferenceDate
        self.endTime = endDate.timeIntervalSinceReferenceDate
    }
    
    func contains(date: Date) -> Bool {
        let timeInterval = date.timeIntervalSinceReferenceDate
        return timeInterval >= startTime && timeInterval <= endTime
    }
    
    func timeRemaining(from date: Date) -> TimeInterval {
        let timeInterval = date.timeIntervalSinceReferenceDate
        return max(0, endTime - timeInterval)
    }
    
    func progress(from date: Date) -> Double {
        let timeInterval = date.timeIntervalSinceReferenceDate
        let elapsed = timeInterval - startTime
        return min(1.0, max(0.0, elapsed / duration))
    }
}