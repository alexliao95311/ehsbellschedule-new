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
        let preferences = UserPreferences.shared
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        let timeInterval = date.timeIntervalSinceReferenceDate
        return filteredPeriods.first { period in
            timeInterval >= period.startTime && timeInterval < period.endTime
        }
    }
    
    func getNextPeriod(at date: Date = Date()) -> Period? {
        let schedule = getCurrentSchedule(for: date)
        let preferences = UserPreferences.shared
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        let timeInterval = date.timeIntervalSinceReferenceDate
        return filteredPeriods.first { period in
            period.startTime > timeInterval
        }
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
    
    func timeUntilNextFilteredPeriod(at date: Date = Date()) -> TimeInterval? {
        let schedule = getCurrentSchedule(for: date)
        let preferences = UserPreferences.shared
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        let timeInterval = date.timeIntervalSinceReferenceDate
        if let nextPeriod = filteredPeriods.first(where: { $0.startTime > timeInterval }) {
            return nextPeriod.startTime - timeInterval
        }
        return nil
    }
    
    func isInPassingPeriod(at date: Date = Date()) -> Bool {
        let schedule = getCurrentSchedule(for: date)
        let preferences = UserPreferences.shared
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        let timeInterval = date.timeIntervalSinceReferenceDate
        
        // Check if we're in a passing period between any two filtered periods
        for i in 0..<filteredPeriods.count - 1 {
            let currentPeriodEnd = filteredPeriods[i].endTime
            let nextPeriodStart = filteredPeriods[i + 1].startTime
            
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
        let preferences = UserPreferences.shared
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        // Check if we're currently in a filtered period
        let timeInterval = date.timeIntervalSinceReferenceDate
        if let currentPeriod = filteredPeriods.first(where: { period in
            timeInterval >= period.startTime && timeInterval < period.endTime
        }) {
            let timeRemaining = currentPeriod.timeRemaining(from: date)
            let progress = currentPeriod.progress(from: date)
            return .inClass(period: currentPeriod, timeRemaining: timeRemaining, progress: progress)
        }
        
        // Check if we're in a passing period between filtered periods
        if isInPassingPeriod(at: date) {
            if let nextPeriod = getNextPeriod(at: date) {
                let timeUntilNext = timeUntilNextPeriod(at: date) ?? 0
                return .passingPeriod(nextPeriod: nextPeriod, timeUntilNext: timeUntilNext)
            }
        }
        
        // Check if we're before the first filtered period
        if let firstPeriod = filteredPeriods.first {
            if timeInterval < firstPeriod.startTime {
                let timeUntilNext = firstPeriod.startTime - timeInterval
                return .beforeSchool(nextPeriod: firstPeriod, timeUntilNext: timeUntilNext)
            }
        }
        
        // Check if we're after the last filtered period
        if let lastPeriod = filteredPeriods.last {
            if timeInterval >= lastPeriod.endTime {
                return .afterSchool
            }
        }
        
        // If we're between periods but not in a passing period, check if there's a next filtered period
        if let nextPeriod = filteredPeriods.first(where: { $0.startTime > timeInterval }) {
            let timeUntilNext = nextPeriod.startTime - timeInterval
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