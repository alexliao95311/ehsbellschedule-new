import SwiftUI

struct InformationView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @State private var selectedScheduleType: ScheduleType = .thursday

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                scheduleTypeSelector

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPeriods, id: \.number) { period in
                            periodCard(for: period)
                                .id("\(period.number)-\(preferences.use24HourFormat)")
                        }
                    }
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Schedule Information")
            .navigationBarTitleDisplayMode(.large)
            .background(Constants.Colors.backgroundGray(preferences.isDarkMode).ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
        .id(preferences.isDarkMode) // Force refresh when dark mode changes
    }

    // MARK: - Schedule Type Selector

    private var scheduleTypeSelector: some View {
        VStack(spacing: 0) {
            Picker("Schedule Type", selection: $selectedScheduleType) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Text(type.abbreviation).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Constants.Layout.padding)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Constants.Colors.textSecondary(preferences.isDarkMode).opacity(0.2))
                .frame(height: 1)
        }
        .background(Constants.Colors.cardBackground(preferences.isDarkMode))
    }

    // MARK: - Filtered Periods (FIXED LOGIC)

    private var filteredPeriods: [Period] {
        // Use our working direct schedule logic instead of ScheduleCalculator
        let periods = getPeriodsForSchedule(selectedScheduleType)
        return periods.filter { period in
            if period.number == 0 && !preferences.showPeriod0 { return false }
            if period.number == 7 && !preferences.showPeriod7 { return false }
            return true
        }
    }

    // MARK: - Working Schedule Logic

    private func getPeriodsForSchedule(_ scheduleType: ScheduleType) -> [Period] {
        let referenceDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 6)) ?? Date()

        switch scheduleType {
        case .monday:
            return [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: referenceDate),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 22, defaultName: "Period 1", for: referenceDate),
                Period(number: 2, startHour: 9, startMinute: 28, endHour: 10, endMinute: 20, defaultName: "Period 2", for: referenceDate),
                Period(number: 3, startHour: 10, startMinute: 26, endHour: 11, endMinute: 18, defaultName: "Period 3", for: referenceDate),
                Period(number: 4, startHour: 11, startMinute: 24, endHour: 12, endMinute: 16, defaultName: "Period 4", for: referenceDate),
                Period(number: 98, startHour: 12, startMinute: 16, endHour: 12, endMinute: 51, defaultName: "Lunch", for: referenceDate),
                Period(number: 99, startHour: 12, startMinute: 57, endHour: 13, endMinute: 29, defaultName: "ACCESS", for: referenceDate),
                Period(number: 5, startHour: 13, startMinute: 35, endHour: 14, endMinute: 27, defaultName: "Period 5", for: referenceDate),
                Period(number: 6, startHour: 14, startMinute: 33, endHour: 15, endMinute: 25, defaultName: "Period 6", for: referenceDate),
                Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7", for: referenceDate)
            ]

        case .tuesday:
            return [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: referenceDate),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 28, defaultName: "Period 1", for: referenceDate),
                Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 32, defaultName: "Period 2", for: referenceDate),
                Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3", for: referenceDate),
                Period(number: 4, startHour: 11, startMinute: 44, endHour: 12, endMinute: 42, defaultName: "Period 4", for: referenceDate),
                Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch", for: referenceDate),
                Period(number: 5, startHour: 13, startMinute: 23, endHour: 14, endMinute: 21, defaultName: "Period 5", for: referenceDate),
                Period(number: 6, startHour: 14, startMinute: 27, endHour: 15, endMinute: 25, defaultName: "Period 6", for: referenceDate),
                Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7", for: referenceDate)
            ]

        case .wednesday:
            return [
                Period(number: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 30, defaultName: "Period 1", for: referenceDate),
                Period(number: 3, startHour: 10, startMinute: 36, endHour: 12, endMinute: 6, defaultName: "Period 3", for: referenceDate),
                Period(number: 98, startHour: 12, startMinute: 6, endHour: 12, endMinute: 41, defaultName: "Lunch", for: referenceDate),
                Period(number: 99, startHour: 12, startMinute: 47, endHour: 13, endMinute: 49, defaultName: "ACCESS", for: referenceDate),
                Period(number: 5, startHour: 13, startMinute: 55, endHour: 15, endMinute: 25, defaultName: "Period 5", for: referenceDate)
            ]

        case .thursday:
            return [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: referenceDate),
                Period(number: 2, startHour: 8, startMinute: 30, endHour: 10, endMinute: 0, defaultName: "Period 2", for: referenceDate),
                Period(number: 4, startHour: 10, startMinute: 6, endHour: 11, endMinute: 36, defaultName: "Period 4", for: referenceDate),
                Period(number: 98, startHour: 11, startMinute: 36, endHour: 12, endMinute: 11, defaultName: "Lunch", for: referenceDate),
                Period(number: 99, startHour: 12, startMinute: 17, endHour: 13, endMinute: 9, defaultName: "ACCESS", for: referenceDate),
                Period(number: 6, startHour: 13, startMinute: 15, endHour: 14, endMinute: 45, defaultName: "Period 6", for: referenceDate),
                Period(number: 7, startHour: 14, startMinute: 51, endHour: 15, endMinute: 56, defaultName: "Period 7", for: referenceDate)
            ]

        case .friday:
            return [
                Period(number: 0, startHour: 7, startMinute: 15, endHour: 8, endMinute: 20, defaultName: "Period 0", for: referenceDate),
                Period(number: 1, startHour: 8, startMinute: 30, endHour: 9, endMinute: 28, defaultName: "Period 1", for: referenceDate),
                Period(number: 2, startHour: 9, startMinute: 34, endHour: 10, endMinute: 32, defaultName: "Period 2", for: referenceDate),
                Period(number: 3, startHour: 10, startMinute: 38, endHour: 11, endMinute: 38, defaultName: "Period 3", for: referenceDate),
                Period(number: 4, startHour: 11, startMinute: 44, endHour: 12, endMinute: 42, defaultName: "Period 4", for: referenceDate),
                Period(number: 98, startHour: 12, startMinute: 42, endHour: 13, endMinute: 17, defaultName: "Lunch", for: referenceDate),
                Period(number: 5, startHour: 13, startMinute: 23, endHour: 14, endMinute: 21, defaultName: "Period 5", for: referenceDate),
                Period(number: 6, startHour: 14, startMinute: 27, endHour: 15, endMinute: 25, defaultName: "Period 6", for: referenceDate),
                Period(number: 7, startHour: 15, startMinute: 31, endHour: 16, endMinute: 36, defaultName: "Period 7", for: referenceDate)
            ]

        case .minimumDay:
            return [
                Period(number: 0, startHour: 7, startMinute: 30, endHour: 8, endMinute: 5, defaultName: "Period 0", for: referenceDate),
                Period(number: 1, startHour: 8, startMinute: 15, endHour: 8, endMinute: 50, defaultName: "Period 1", for: referenceDate),
                Period(number: 2, startHour: 9, startMinute: 0, endHour: 9, endMinute: 35, defaultName: "Period 2", for: referenceDate),
                Period(number: 3, startHour: 9, startMinute: 45, endHour: 10, endMinute: 20, defaultName: "Period 3", for: referenceDate),
                Period(number: 4, startHour: 10, startMinute: 30, endHour: 11, endMinute: 5, defaultName: "Period 4", for: referenceDate),
                Period(number: 5, startHour: 11, startMinute: 15, endHour: 11, endMinute: 50, defaultName: "Period 5", for: referenceDate),
                Period(number: 6, startHour: 12, startMinute: 0, endHour: 12, endMinute: 35, defaultName: "Period 6", for: referenceDate),
                Period(number: 7, startHour: 12, startMinute: 45, endHour: 13, endMinute: 20, defaultName: "Period 7", for: referenceDate)
            ]
        }
    }

    // MARK: - Period Card (ORIGINAL UI)

    private func periodCard(for period: Period) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let classInfo = preferences.getClassInfo(for: period)

                    Text(classInfo.displayName)
                        .font(Constants.Fonts.headline)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                        .fontWeight(.semibold)

                    if classInfo.hasDetails {
                        Text(classInfo.detailsText)
                            .font(Constants.Fonts.caption)
                            .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                    }

                    Text(period.displayName)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }

                Spacer()

                periodNumberBadge(period.number)
            }

            // Time Information
            timeInfoSection(for: period)
        }
        .padding(20)
        .background(Constants.Colors.cardBackground(preferences.isDarkMode))
        .cornerRadius(Constants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func periodNumberBadge(_ number: Int) -> some View {
        Text("\(number == 99 ? "A" : number == 98 ? "L" : String(number))")
            .font(Constants.Fonts.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Constants.Colors.primaryGreen(preferences.isDarkMode), Constants.Colors.secondaryGreen(preferences.isDarkMode)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private func timeInfoSection(for period: Period) -> some View {
        HStack(spacing: 12) {
            timeInfoItem(
                icon: "clock",
                title: "Start Time",
                value: TimeFormatter.shared.formatTime(period.startDate, use24Hour: preferences.use24HourFormat),
                color: Constants.Colors.success
            )

            timeInfoItem(
                icon: "clock.badge.checkmark",
                title: "End Time",
                value: TimeFormatter.shared.formatTime(period.endDate, use24Hour: preferences.use24HourFormat),
                color: Constants.Colors.warning
            )

            timeInfoItem(
                icon: "timer",
                title: "Duration",
                value: TimeFormatter.shared.formatDuration(period.duration),
                color: Constants.Colors.primaryGreen(preferences.isDarkMode)
            )
        }
    }

    private func timeInfoItem(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))

                Text(value)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Schedule Summary View (ORIGINAL)

struct ScheduleSummaryView: View {
    let scheduleType: ScheduleType
    @ObservedObject private var preferences = UserPreferences.shared

    var body: some View {
        let schedule = ScheduleCalculator.shared.getScheduleForType(scheduleType)
        let filteredPeriods = schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )

        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule Summary")
                .font(Constants.Fonts.headline)
                .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                summaryRow(
                    icon: "number",
                    title: "Total Periods",
                    value: "\(filteredPeriods.count)"
                )

                summaryRow(
                    icon: "clock",
                    title: "School Day Duration",
                    value: schoolDayDuration(for: filteredPeriods)
                )

                if let firstPeriod = filteredPeriods.first,
                   let lastPeriod = filteredPeriods.last {
                    summaryRow(
                        icon: "sunrise",
                        title: "First Period",
                        value: TimeFormatter.shared.formatTime(firstPeriod.startDate, use24Hour: preferences.use24HourFormat)
                    )
                    .id("first-time-\(preferences.use24HourFormat)")

                    summaryRow(
                        icon: "sunset",
                        title: "Last Period Ends",
                        value: TimeFormatter.shared.formatTime(lastPeriod.endDate, use24Hour: preferences.use24HourFormat)
                    )
                    .id("last-time-\(preferences.use24HourFormat)")
                }
            }
        }
        .padding(20)
        .background(Constants.Colors.cardBackground(preferences.isDarkMode))
        .cornerRadius(Constants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                .frame(width: 20)

            Text(title)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))

            Spacer()

            Text(value)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                .fontWeight(.medium)
        }
    }

    private func schoolDayDuration(for periods: [Period]) -> String {
        guard let firstPeriod = periods.first,
              let lastPeriod = periods.last else {
            return "N/A"
        }

        let duration = lastPeriod.endTime - firstPeriod.startTime
        return TimeFormatter.shared.formatDuration(duration)
    }
}

#Preview {
    InformationView()
}