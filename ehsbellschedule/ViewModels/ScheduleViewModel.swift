import Foundation
import Combine

class ScheduleViewModel: ObservableObject {
    @Published var scheduleStatus: ScheduleStatus = .noSchool
    @Published var currentScheduleType: String = ""
    @Published var currentScheduleAbbreviation: String = ""
    @Published var currentDateString: String = ""
    @Published var upcomingPeriods: [Period] = []
    
    private var timer: Timer?
    private let scheduleCalculator = ScheduleCalculator.shared
    private let timeFormatter = TimeFormatter.shared
    private let dataService = DataPersistenceService.shared
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    init() {
        updateScheduleStatus()
        updateCurrentDate()
        updateUpcomingPeriods()
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.Timing.countdownUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateScheduleStatus()
            self?.updateWidgetData()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Update Methods
    
    private func updateScheduleStatus() {
        let newStatus = scheduleCalculator.getScheduleStatus()
        let currentSchedule = scheduleCalculator.getCurrentSchedule()
        let newScheduleType = currentSchedule.type.displayName
        let newScheduleAbbreviation = currentSchedule.type.abbreviation
        
        DispatchQueue.main.async {
            self.scheduleStatus = newStatus
            self.currentScheduleType = newScheduleType
            self.currentScheduleAbbreviation = newScheduleAbbreviation
        }
        
        updateUpcomingPeriods()
    }
    
    private func updateCurrentDate() {
        let now = Date()
        DispatchQueue.main.async {
            self.currentDateString = self.dateFormatter.string(from: now)
        }
    }
    
    private func updateUpcomingPeriods() {
        let currentSchedule = scheduleCalculator.getCurrentSchedule()
        let preferences = UserPreferences.shared
        
        let filteredPeriods = currentSchedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
        
        let now = Date()
        let remaining = filteredPeriods.filter { period in
            period.startTime > now.timeIntervalSinceReferenceDate
        }
        
        DispatchQueue.main.async {
            self.upcomingPeriods = remaining
        }
    }
    
    private func updateWidgetData() {
        let widgetData = createWidgetData()
        dataService.saveWidgetData(widgetData)
    }
    
    private func createWidgetData() -> WidgetData {
        let preferences = UserPreferences.shared
        
        switch scheduleStatus {
        case .inClass(let period, let timeRemaining, let progress):
            let classInfo = preferences.getClassInfo(for: period)
            return WidgetData(
                currentPeriodName: classInfo.displayName,
                currentPeriodEndTime: period.endDate,
                currentPeriodTeacher: classInfo.teacher.isEmpty ? nil : classInfo.teacher,
                currentPeriodRoom: classInfo.room.isEmpty ? nil : classInfo.room,
                scheduleStatus: "In Class",
                timeRemaining: timeRemaining,
                progress: progress
            )
            
        case .passingPeriod(let nextPeriod, let timeUntilNext):
            let classInfo = preferences.getClassInfo(for: nextPeriod)
            return WidgetData(
                nextPeriodName: classInfo.displayName,
                nextPeriodStartTime: nextPeriod.startDate,
                nextPeriodTeacher: classInfo.teacher.isEmpty ? nil : classInfo.teacher,
                nextPeriodRoom: classInfo.room.isEmpty ? nil : classInfo.room,
                scheduleStatus: "Passing Period",
                timeRemaining: timeUntilNext
            )
            
        case .beforeSchool(let nextPeriod, let timeUntilNext):
            let classInfo = preferences.getClassInfo(for: nextPeriod)
            return WidgetData(
                nextPeriodName: classInfo.displayName,
                nextPeriodStartTime: nextPeriod.startDate,
                nextPeriodTeacher: classInfo.teacher.isEmpty ? nil : classInfo.teacher,
                nextPeriodRoom: classInfo.room.isEmpty ? nil : classInfo.room,
                scheduleStatus: "Before School",
                timeRemaining: timeUntilNext
            )
            
        case .afterSchool:
            return WidgetData(scheduleStatus: "After School")
            
        case .noSchool:
            return WidgetData(scheduleStatus: "No School")
        }
    }
    
    // MARK: - Public Methods
    
    func refreshSchedule() {
        updateScheduleStatus()
        updateCurrentDate()
        updateUpcomingPeriods()
        updateWidgetData()
    }
    
    func getFormattedTimeRange(for period: Period, use24Hour: Bool) -> String {
        return timeFormatter.formatTimeRange(
            start: period.startDate,
            end: period.endDate,
            use24Hour: use24Hour
        )
    }
    
    func getFormattedCountdown(_ timeInterval: TimeInterval) -> String {
        return timeFormatter.formatCountdown(timeInterval)
    }
    
    deinit {
        stopTimer()
    }
}