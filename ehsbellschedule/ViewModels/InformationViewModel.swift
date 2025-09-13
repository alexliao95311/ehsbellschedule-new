import Foundation
import Combine

class InformationViewModel: ObservableObject {
    @Published var selectedScheduleType: ScheduleType = .monday
    @Published var filteredPeriods: [Period] = []
    @Published var scheduleAnalytics: ScheduleAnalytics = ScheduleAnalytics()

    private let preferences = UserPreferences.shared
    private var cancellables = Set<AnyCancellable>()

    // Static schedule data - no date dependencies
    private let scheduleData: [ScheduleType: [(number: Int, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, name: String)]] = [
        .monday: [
            (0, 7, 15, 8, 20, "Period 0"),
            (1, 8, 30, 9, 22, "Period 1"),
            (2, 9, 28, 10, 20, "Period 2"),
            (3, 10, 26, 11, 18, "Period 3"),
            (4, 11, 24, 12, 16, "Period 4"),
            (98, 12, 16, 12, 51, "Lunch"),
            (99, 12, 57, 13, 29, "ACCESS Period"),
            (5, 13, 35, 14, 27, "Period 5"),
            (6, 14, 33, 15, 25, "Period 6"),
            (7, 15, 31, 16, 36, "Period 7")
        ],
        .tuesday: [
            (0, 7, 15, 8, 20, "Period 0"),
            (1, 8, 30, 9, 28, "Period 1"),
            (2, 9, 34, 10, 32, "Period 2"),
            (3, 10, 38, 11, 38, "Period 3"),
            (4, 11, 44, 12, 42, "Period 4"),
            (98, 12, 42, 13, 17, "Lunch"),
            (5, 13, 23, 14, 21, "Period 5"),
            (6, 14, 27, 15, 25, "Period 6"),
            (7, 15, 31, 16, 36, "Period 7")
        ],
        .wednesday: [
            (1, 9, 0, 10, 30, "Period 1"),
            (3, 10, 36, 12, 6, "Period 3"),
            (98, 12, 6, 12, 41, "Lunch"),
            (99, 12, 47, 13, 49, "ACCESS Period"),
            (5, 13, 55, 15, 25, "Period 5")
        ],
        .thursday: [
            (0, 7, 15, 8, 20, "Period 0"),
            (2, 8, 30, 10, 0, "Period 2"),
            (4, 10, 6, 11, 36, "Period 4"),
            (98, 11, 36, 12, 11, "Lunch"),
            (99, 12, 17, 13, 9, "ACCESS Period"),
            (6, 13, 15, 14, 45, "Period 6"),
            (7, 14, 51, 15, 56, "Period 7")
        ],
        .friday: [
            (0, 7, 15, 8, 20, "Period 0"),
            (1, 8, 30, 9, 28, "Period 1"),
            (2, 9, 34, 10, 32, "Period 2"),
            (3, 10, 38, 11, 38, "Period 3"),
            (4, 11, 44, 12, 42, "Period 4"),
            (98, 12, 42, 13, 17, "Lunch"),
            (5, 13, 23, 14, 21, "Period 5"),
            (6, 14, 27, 15, 25, "Period 6"),
            (7, 15, 31, 16, 36, "Period 7")
        ],
        .minimumDay: [
            (0, 7, 30, 8, 5, "Period 0"),
            (1, 8, 15, 8, 50, "Period 1"),
            (2, 9, 0, 9, 35, "Period 2"),
            (3, 9, 45, 10, 20, "Period 3"),
            (4, 10, 30, 11, 5, "Period 4"),
            (5, 11, 15, 11, 50, "Period 5"),
            (6, 12, 0, 12, 35, "Period 6"),
            (7, 12, 45, 13, 20, "Period 7")
        ]
    ]

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
        // DEBUG: Print what schedule type we're switching to
        print("🔄 SWITCHING TO SCHEDULE: \(selectedScheduleType.rawValue)")

        // Get periods for the selected schedule type
        let periods = createPeriodsForScheduleType(selectedScheduleType)

        // DEBUG: Print how many periods we found
        print("📅 Found \(periods.count) periods for \(selectedScheduleType.rawValue)")

        // Filter based on user preferences
        filteredPeriods = periods.filter { period in
            if period.number == 0 && !preferences.showPeriod0 { return false }
            if period.number == 7 && !preferences.showPeriod7 { return false }
            return true
        }

        // DEBUG: Print final filtered count
        print("✅ Final filtered periods: \(filteredPeriods.count)")
    }

    private func createPeriodsForScheduleType(_ scheduleType: ScheduleType) -> [Period] {
        guard let periodData = scheduleData[scheduleType] else {
            print("❌ No data found for schedule type: \(scheduleType.rawValue)")
            return []
        }

        print("🔍 Raw data for \(scheduleType.rawValue): \(periodData.map { $0.number }.sorted())")

        // Use a fixed reference date for consistency
        let referenceDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 6)) ?? Date()

        let periods = periodData.map { data in
            Period(
                number: data.number,
                startHour: data.startHour,
                startMinute: data.startMinute,
                endHour: data.endHour,
                endMinute: data.endMinute,
                defaultName: data.name,
                for: referenceDate
            )
        }

        print("📋 Created periods for \(scheduleType.rawValue): \(periods.map { $0.number }.sorted())")
        return periods
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
            let periods = createPeriodsForScheduleType(type)
            let filteredPeriods = periods.filter { period in
                if period.number == 0 && !preferences.showPeriod0 { return false }
                if period.number == 7 && !preferences.showPeriod7 { return false }
                return true
            }
            return ScheduleTypeInfo(
                type: type,
                periods: filteredPeriods,
                totalDuration: filteredPeriods.reduce(0) { $0 + $1.duration }
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