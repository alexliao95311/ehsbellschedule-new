import Foundation

class ScheduleCalculator {
    static let shared = ScheduleCalculator()
    
    private init() {}
    
    func getCurrentSchedule(for date: Date = Date()) -> Schedule {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        switch weekday {
        case 2: // Monday
            return Schedule.mondaySchedule
        case 3: // Tuesday
            return Schedule.tuesdaySchedule
        case 4: // Wednesday
            return Schedule.wednesdaySchedule
        case 5: // Thursday
            return Schedule.thursdaySchedule
        case 6: // Friday
            return Schedule.fridaySchedule
        default: // Weekend or other days - default to Monday
            return Schedule.mondaySchedule
        }
    }
    
    func getCurrentPeriod(at date: Date = Date()) -> Period? {
        let schedule = getCurrentSchedule(for: date)
        return schedule.getCurrentPeriod(at: date)
    }
    
    func getNextPeriod(at date: Date = Date()) -> Period? {
        let schedule = getCurrentSchedule(for: date)
        return schedule.getNextPeriod(at: date)
    }
    
    func isSchoolDay(date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday >= 2 && weekday <= 6 // Monday through Friday
    }
    
    func timeUntilNextPeriod(at date: Date = Date()) -> TimeInterval? {
        guard let nextPeriod = getNextPeriod(at: date) else { return nil }
        return nextPeriod.startTime - date.timeIntervalSinceReferenceDate
    }
    
    func isInPassingPeriod(at date: Date = Date()) -> Bool {
        let schedule = getCurrentSchedule(for: date)
        let timeInterval = date.timeIntervalSinceReferenceDate
        
        for i in 0..<schedule.periods.count - 1 {
            let currentPeriodEnd = schedule.periods[i].endTime
            let nextPeriodStart = schedule.periods[i + 1].startTime
            
            if timeInterval > currentPeriodEnd && timeInterval < nextPeriodStart {
                return true
            }
        }
        
        return false
    }
    
    func getScheduleForType(_ type: ScheduleType) -> Schedule {
        switch type {
        case .monday:
            return Schedule.mondaySchedule
        case .tuesday:
            return Schedule.tuesdaySchedule
        case .wednesday:
            return Schedule.wednesdaySchedule
        case .thursday:
            return Schedule.thursdaySchedule
        case .friday:
            return Schedule.fridaySchedule
        case .minimumDay:
            return Schedule.minimumDaySchedule
        }
    }
    
    func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func getScheduleStatus(at date: Date = Date()) -> ScheduleStatus {
        guard isSchoolDay(date: date) else {
            return .noSchool
        }
        
        let schedule = getCurrentSchedule(for: date)
        
        if let currentPeriod = schedule.getCurrentPeriod(at: date) {
            let timeRemaining = currentPeriod.timeRemaining(from: date)
            let progress = currentPeriod.progress(from: date)
            return .inClass(period: currentPeriod, timeRemaining: timeRemaining, progress: progress)
        }
        
        if isInPassingPeriod(at: date) {
            if let nextPeriod = getNextPeriod(at: date) {
                let timeUntilNext = timeUntilNextPeriod(at: date) ?? 0
                return .passingPeriod(nextPeriod: nextPeriod, timeUntilNext: timeUntilNext)
            }
        }
        
        if let nextPeriod = getNextPeriod(at: date) {
            let timeUntilNext = timeUntilNextPeriod(at: date) ?? 0
            return .beforeSchool(nextPeriod: nextPeriod, timeUntilNext: timeUntilNext)
        }
        
        return .afterSchool
    }
}

enum ScheduleStatus {
    case noSchool
    case beforeSchool(nextPeriod: Period, timeUntilNext: TimeInterval)
    case inClass(period: Period, timeRemaining: TimeInterval, progress: Double)
    case passingPeriod(nextPeriod: Period, timeUntilNext: TimeInterval)
    case afterSchool
}