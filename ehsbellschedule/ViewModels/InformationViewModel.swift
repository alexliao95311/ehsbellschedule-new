import Foundation
import Combine

class InformationViewModel: ObservableObject {
    @Published var selectedScheduleType: ScheduleType = .monday
    @Published var filteredPeriods: [Period] = []
    @Published var scheduleAnalytics: ScheduleAnalytics = ScheduleAnalytics()
    
    private let preferences = UserPreferences.shared
    private let scheduleCalculator = ScheduleCalculator.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Automatically set to current day's schedule
        selectedScheduleType = ScheduleType.getCurrentDayScheduleType()
        
        setupBindings()
        updateFilteredPeriods()
        calculateAnalytics()
    }
    
    private func setupBindings() {
        // Update periods when schedule type changes
        $selectedScheduleType
            .sink { [weak self] _ in
                self?.updateFilteredPeriods()
                self?.calculateAnalytics()
            }
            .store(in: &cancellables)
        
        // Update periods when preferences change
        preferences.$showPeriod0
            .combineLatest(preferences.$showPeriod7)
            .sink { [weak self] _, _ in
                self?.updateFilteredPeriods()
                self?.calculateAnalytics()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredPeriods() {
        let schedule = scheduleCalculator.getScheduleForType(selectedScheduleType)
        filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
    }
    
    private func calculateAnalytics() {
        guard !filteredPeriods.isEmpty else {
            scheduleAnalytics = ScheduleAnalytics()
            return
        }
        
        let totalPeriods = filteredPeriods.count
        let totalClassTime = filteredPeriods.reduce(0) { $0 + $1.duration }
        
        guard let firstPeriod = filteredPeriods.first,
              let lastPeriod = filteredPeriods.last else {
            scheduleAnalytics = ScheduleAnalytics()
            return
        }
        
        let schoolDayDuration = lastPeriod.endTime - firstPeriod.startTime
        let breakTime = schoolDayDuration - totalClassTime
        
        let averagePeriodLength = totalClassTime / Double(totalPeriods)
        let longestPeriod = filteredPeriods.max { $0.duration < $1.duration }
        let shortestPeriod = filteredPeriods.min { $0.duration < $1.duration }
        
        scheduleAnalytics = ScheduleAnalytics(
            totalPeriods: totalPeriods,
            totalClassTime: totalClassTime,
            schoolDayDuration: schoolDayDuration,
            breakTime: breakTime,
            averagePeriodLength: averagePeriodLength,
            longestPeriod: longestPeriod,
            shortestPeriod: shortestPeriod,
            firstPeriodStart: firstPeriod.startDate,
            lastPeriodEnd: lastPeriod.endDate
        )
    }
    
    // MARK: - Public Methods
    
    func getCustomClassName(for period: Period) -> String {
        return preferences.getClassName(for: period)
    }
    
    func getPeriodProgress(for period: Period, at date: Date = Date()) -> Double {
        return period.progress(from: date)
    }
    
    func getScheduleComparison() -> ScheduleComparison {
        let allSchedules = ScheduleType.allCases.map { type in
            let schedule = scheduleCalculator.getScheduleForType(type)
            let periods = schedule.filteredPeriods(
                showPeriod0: preferences.showPeriod0,
                showPeriod7: preferences.showPeriod7
            )
            return ScheduleTypeInfo(
                type: type,
                periods: periods,
                totalDuration: periods.reduce(0) { $0 + $1.duration }
            )
        }
        
        return ScheduleComparison(schedules: allSchedules)
    }
}

// MARK: - Supporting Models

struct ScheduleAnalytics {
    let totalPeriods: Int
    let totalClassTime: TimeInterval
    let schoolDayDuration: TimeInterval
    let breakTime: TimeInterval
    let averagePeriodLength: TimeInterval
    let longestPeriod: Period?
    let shortestPeriod: Period?
    let firstPeriodStart: Date
    let lastPeriodEnd: Date
    
    init() {
        self.totalPeriods = 0
        self.totalClassTime = 0
        self.schoolDayDuration = 0
        self.breakTime = 0
        self.averagePeriodLength = 0
        self.longestPeriod = nil
        self.shortestPeriod = nil
        self.firstPeriodStart = Date()
        self.lastPeriodEnd = Date()
    }
    
    init(totalPeriods: Int,
         totalClassTime: TimeInterval,
         schoolDayDuration: TimeInterval,
         breakTime: TimeInterval,
         averagePeriodLength: TimeInterval,
         longestPeriod: Period?,
         shortestPeriod: Period?,
         firstPeriodStart: Date,
         lastPeriodEnd: Date) {
        self.totalPeriods = totalPeriods
        self.totalClassTime = totalClassTime
        self.schoolDayDuration = schoolDayDuration
        self.breakTime = breakTime
        self.averagePeriodLength = averagePeriodLength
        self.longestPeriod = longestPeriod
        self.shortestPeriod = shortestPeriod
        self.firstPeriodStart = firstPeriodStart
        self.lastPeriodEnd = lastPeriodEnd
    }
}

struct ScheduleTypeInfo {
    let type: ScheduleType
    let periods: [Period]
    let totalDuration: TimeInterval
}

struct ScheduleComparison {
    let schedules: [ScheduleTypeInfo]
    
    var longestSchedule: ScheduleTypeInfo? {
        schedules.max { $0.totalDuration < $1.totalDuration }
    }
    
    var shortestSchedule: ScheduleTypeInfo? {
        schedules.min { $0.totalDuration < $1.totalDuration }
    }
    
    var averageDuration: TimeInterval {
        guard !schedules.isEmpty else { return 0 }
        let total = schedules.reduce(0) { $0 + $1.totalDuration }
        return total / Double(schedules.count)
    }
}