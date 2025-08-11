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
}

struct Schedule: Identifiable, Codable {
    let id = UUID()
    let type: ScheduleType
    let periods: [Period]
    
    static let mondaySchedule = Schedule(
        type: .monday,
        periods: [
            Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0"),
            Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 22, defaultName: "Period 1"),
            Period(number: 2, startHour: 9, startMinute: 28, endHour: 10, endMinute: 20, defaultName: "Period 2"),
            Period(number: 3, startHour: 10, startMinute: 26, endHour: 11, endMinute: 18, defaultName: "Period 3"),
            Period(number: 4, startHour: 11, startMinute: 24, endHour: 12, endMinute: 16, defaultName: "Period 4"),
            Period(number: 98, startHour: 12, startMinute: 16, endHour: 12, endMinute: 51, defaultName: "Lunch"),
            Period(number: 99, startHour: 12, startMinute: 57, endHour: 13, endMinute: 29, defaultName: "ACCESS Period"),
            Period(number: 5, startHour: 13, startMinute: 35, endHour: 14, endMinute: 27, defaultName: "Period 5"),
            Period(number: 6, startHour: 14, startMinute: 33, endHour: 15, endMinute: 25, defaultName: "Period 6"),
            Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7")
        ]
    )
    
    static let tuesdaySchedule = Schedule(
        type: .tuesday,
        periods: [
            Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0"),
            Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 28, defaultName: "Period 1"),
            Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 32, defaultName: "Period 2"),
            Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3"),
            Period(number: 4, startHour: 11, startMinute: 44, endHour: 12, endMinute: 42, defaultName: "Period 4"),
            Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch"),
            Period(number: 5, startHour: 13, startMinute: 23, endHour: 14, endMinute: 21, defaultName: "Period 5"),
            Period(number: 6, startHour: 14, startMinute: 27, endHour: 15, endMinute: 25, defaultName: "Period 6"),
            Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7")
        ]
    )
    
    static let wednesdaySchedule = Schedule(
        type: .wednesday,
        periods: [
            Period(number: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 30, defaultName: "Period 1"),
            Period(number: 3, startHour: 10, startMinute: 36, endHour: 12, endMinute: 6, defaultName: "Period 3"),
            Period(number: 98, startHour: 12, startMinute: 6, endHour: 12, endMinute: 41, defaultName: "Lunch"),
            Period(number: 99, startHour: 12, startMinute: 47, endHour: 13, endMinute: 49, defaultName: "ACCESS Period"),
            Period(number: 5, startHour: 13, startMinute: 55, endHour: 15, endMinute: 25, defaultName: "Period 5")
        ]
    )
    
    static let thursdaySchedule = Schedule(
        type: .thursday,
        periods: [
            Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0"),
            Period(number: 2, startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, defaultName: "Period 2"),
            Period(number: 4, startHour: 10, startMinute: 6, endHour: 11, endMinute: 36, defaultName: "Period 4"),
            Period(number: 98, startHour: 11, startMinute: 36, endHour: 12, endMinute: 11, defaultName: "Lunch"),
            Period(number: 99, startHour: 12, startMinute: 17, endHour: 13, endMinute: 9, defaultName: "ACCESS Period"),
            Period(number: 6, startHour: 13, startMinute: 15, endHour: 14, endMinute: 45, defaultName: "Period 6"),
            Period(number: 7, startHour: 14, startMinute: 51, endHour: 15, endMinute: 56, defaultName: "Period 7")
        ]
    )
    
    static let fridaySchedule = Schedule(
        type: .friday,
        periods: [
            Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0"),
            Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 28, defaultName: "Period 1"),
            Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 32, defaultName: "Period 2"),
            Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3"),
            Period(number: 4, startHour: 11, startMinute: 44, endHour: 12, endMinute: 42, defaultName: "Period 4"),
            Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch"),
            Period(number: 5, startHour: 13, startMinute: 23, endHour: 14, endMinute: 21, defaultName: "Period 5"),
            Period(number: 6, startHour: 14, startMinute: 27, endHour: 15, endMinute: 25, defaultName: "Period 6"),
            Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7")
        ]
    )
    
    static let minimumDaySchedule = Schedule(
        type: .minimumDay,
        periods: [
            Period(number: 0, startHour: 7, startMinute: 30, endHour: 8, endMinute: 5, defaultName: "Period 0"),
            Period(number: 1, startHour: 8, startMinute: 15, endHour: 8, endMinute: 50, defaultName: "Period 1"),
            Period(number: 2, startHour: 9, startMinute: 0, endHour: 9, endMinute: 35, defaultName: "Period 2"),
            Period(number: 3, startHour: 9, startMinute: 45, endHour: 10, endMinute: 20, defaultName: "Period 3"),
            Period(number: 4, startHour: 10, startMinute: 30, endHour: 11, endMinute: 5, defaultName: "Period 4"),
            Period(number: 5, startHour: 11, startMinute: 15, endHour: 11, endMinute: 50, defaultName: "Period 5"),
            Period(number: 6, startHour: 12, startMinute: 0, endHour: 12, endMinute: 35, defaultName: "Period 6"),
            Period(number: 7, startHour: 12, startMinute: 45, endHour: 13, endMinute: 20, defaultName: "Period 7")
        ]
    )
    
    static let allSchedules: [Schedule] = [
        mondaySchedule,
        tuesdaySchedule,
        wednesdaySchedule,
        thursdaySchedule,
        fridaySchedule,
        minimumDaySchedule
    ]
    
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