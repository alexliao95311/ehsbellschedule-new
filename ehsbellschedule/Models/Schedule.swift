import Foundation

enum ScheduleType: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"  
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case minimumDay = "Minimum Day"
    
    var displayName: String {
        return self.rawValue
    }
    
    var abbreviation: String {
        switch self {
        case .monday:
            return "Mon"
        case .tuesday:
            return "Tues"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thurs"
        case .friday:
            return "Fri"
        case .minimumDay:
            return "Min"
        }
    }
    
    var shortDisplayName: String {
        return abbreviation
    }
    
    static func getCurrentDayScheduleType() -> ScheduleType {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        switch weekday {
        case 2: // Monday
            return .monday
        case 3: // Tuesday
            return .tuesday
        case 4: // Wednesday
            return .wednesday
        case 5: // Thursday
            return .thursday
        case 6: // Friday
            return .friday
        default: // Weekend (Sunday=1, Saturday=7) or other days - default to Monday
            return .monday
        }
    }
}

struct Schedule: Identifiable, Codable {
    let id = UUID()
    let type: ScheduleType
    let periods: [Period]
    let referenceDate: Date
    
    static func mondaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .monday,
            periods: [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: date),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 20, defaultName: "Period 1", for: date),
                Period(number: 2, startHour: 9, startMinute: 28, endHour: 10, endMinute: 18, defaultName: "Period 2", for: date),
                Period(number: 3, startHour: 10, startMinute: 26, endHour: 11, endMinute: 16, defaultName: "Period 3", for: date),
                Period(number: 4, startHour: 11, startMinute: 24, endHour: 12, endMinute: 14, defaultName: "Period 4", for: date),
                Period(number: 98, startHour: 12, startMinute: 14, endHour: 12, endMinute: 49, defaultName: "Lunch", for: date),
                Period(number: 99, startHour: 12, startMinute: 57, endHour: 13, endMinute: 29, defaultName: "ACCESS Period", for: date),
                Period(number: 5, startHour: 13, startMinute: 37, endHour: 14, endMinute: 27, defaultName: "Period 5", for: date),
                Period(number: 6, startHour: 14, startMinute: 35, endHour: 15, endMinute: 25, defaultName: "Period 6", for: date),
                Period(number: 7, startHour: 15, startMinute: 33, endHour: 16, endMinute: 38, defaultName: "Period 7", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func tuesdaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .tuesday,
            periods: [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: date),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 26, defaultName: "Period 1", for: date),
                Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 30, defaultName: "Period 2", for: date),
                Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3", for: date),
                Period(number: 4, startHour: 11, startMinute: 46, endHour: 12, endMinute: 42, defaultName: "Period 4", for: date),
                Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch", for: date),
                Period(number: 5, startHour: 13, startMinute: 25, endHour: 14, endMinute: 21, defaultName: "Period 5", for: date),
                Period(number: 6, startHour: 14, startMinute: 29, endHour: 15, endMinute: 25, defaultName: "Period 6", for: date),
                Period(number: 7, startHour: 15, startMinute: 33, endHour: 16, endMinute: 38, defaultName: "Period 7", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func wednesdaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .wednesday,
            periods: [
                Period(number: 1, startHour: 9, startMinute: 00, endHour: 10, endMinute: 28, defaultName: "Period 1", for: date),
                Period(number: 3, startHour: 10, startMinute: 36, endHour: 12, endMinute: 04, defaultName: "Period 3", for: date),
                Period(number: 98, startHour: 12, startMinute: 04, endHour: 12, endMinute: 39, defaultName: "Lunch", for: date),
                Period(number: 99, startHour: 12, startMinute: 47, endHour: 13, endMinute: 49, defaultName: "ACCESS Period", for: date),
                Period(number: 5, startHour: 13, startMinute: 57, endHour: 15, endMinute: 25, defaultName: "Period 5", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func thursdaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .thursday,
            periods: [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: date),
                Period(number: 2, startHour: 8, startMinute: 30, endHour: 9, endMinute: 58, defaultName: "Period 2", for: date),
                Period(number: 4, startHour: 10, startMinute: 06, endHour: 11, endMinute: 34, defaultName: "Period 4", for: date),
                Period(number: 98, startHour: 11, startMinute: 34, endHour: 12, endMinute: 09, defaultName: "Lunch", for: date),
                Period(number: 99, startHour: 12, startMinute: 17, endHour: 13, endMinute: 09, defaultName: "ACCESS Period", for: date),
                Period(number: 6, startHour: 13, startMinute: 17, endHour: 14, endMinute: 45, defaultName: "Period 6", for: date),
                Period(number: 7, startHour: 14, startMinute: 53, endHour: 15, endMinute: 58, defaultName: "Period 7", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func fridaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .friday,
            periods: [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: date),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 26, defaultName: "Period 1", for: date),
                Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 30, defaultName: "Period 2", for: date),
                Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3", for: date),
                Period(number: 4, startHour: 11, startMinute: 46, endHour: 12, endMinute: 42, defaultName: "Period 4", for: date),
                Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch", for: date),
                Period(number: 5, startHour: 13, startMinute: 25, endHour: 14, endMinute: 21, defaultName: "Period 5", for: date),
                Period(number: 6, startHour: 14, startMinute: 29, endHour: 15, endMinute: 25, defaultName: "Period 6", for: date),
                Period(number: 7, startHour: 15, startMinute: 33, endHour: 16, endMinute: 38, defaultName: "Period 7", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func minimumDaySchedule(for date: Date = Date()) -> Schedule {
        Schedule(
            type: .minimumDay,
            periods: [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: date),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 00, defaultName: "Period 1", for: date),
                Period(number: 2, startHour: 9, startMinute: 07, endHour: 9, endMinute: 37, defaultName: "Period 2", for: date),
                Period(number: 3, startHour: 9, startMinute: 44, endHour: 10, endMinute: 14, defaultName: "Period 3", for: date),
                Period(number: 4, startHour: 10, startMinute: 21, endHour: 10, endMinute: 51, defaultName: "Period 4", for: date),
                Period(number: 98, startHour: 10, startMinute: 51, endHour: 11, endMinute: 06, defaultName: "Brunch", for: date),
                Period(number: 5, startHour: 11, startMinute: 13, endHour: 11, endMinute: 43, defaultName: "Period 5", for: date),
                Period(number: 6, startHour: 11, startMinute: 50, endHour: 12, endMinute: 20, defaultName: "Period 6", for: date),
                Period(number: 7, startHour: 12, startMinute: 27, endHour: 12, endMinute: 57, defaultName: "Period 7", for: date)
            ],
            referenceDate: date
        )
    }
    
    static func allSchedules(for date: Date = Date()) -> [Schedule] {
        [
            mondaySchedule(for: date),
            tuesdaySchedule(for: date),
            wednesdaySchedule(for: date),
            thursdaySchedule(for: date),
            fridaySchedule(for: date),
            minimumDaySchedule(for: date)
        ]
    }
    
    func getCurrentPeriod(at date: Date = Date()) -> Period? {
        return periods.first { $0.contains(date: date) }
    }
    
    func getNextPeriod(at date: Date = Date()) -> Period? {
        let timeInterval = date.timeIntervalSinceReferenceDate
        return periods.first { $0.startTime > timeInterval }
    }
    
    func filteredPeriods(showPeriod0: Bool, showPeriod7: Bool) -> [Period] {
        return periods.filter { period in
            if period.number == 0 && !showPeriod0 { return false }
            if period.number == 7 && !showPeriod7 { return false }
            return true
        }
    }
}