import SwiftUI

struct InformationView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @State private var selectedScheduleType: ScheduleType = .monday
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                scheduleTypeSelector
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPeriods, id: \.number) { period in
                            periodCard(for: period)
                                .id("\(period.number)-false")
                        }
                    }
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Schedule Information")
            .navigationBarTitleDisplayMode(.large)
            .background(Constants.Colors.backgroundGray.ignoresSafeArea())
        }
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
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
        .background(Constants.Colors.cardBackground)
    }
    
    // MARK: - Filtered Periods
    
    private var filteredPeriods: [Period] {
        let schedule = ScheduleCalculator.shared.getScheduleForType(selectedScheduleType)
        return schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        )
    }
    
    // MARK: - Period Card
    
    private func periodCard(for period: Period) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let classInfo = preferences.getClassInfo(for: period)
                    
                    Text(classInfo.displayName)
                        .font(Constants.Fonts.headline)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .fontWeight(.semibold)
                    
                    if classInfo.hasDetails {
                        Text(classInfo.detailsText)
                            .font(Constants.Fonts.caption)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    Text(period.displayName)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                periodNumberBadge(period.number)
            }
            
            // Time Information
            timeInfoSection(for: period)
        }
        .padding(20)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func periodNumberBadge(_ number: Int) -> some View {
        Text("\(number)")
            .font(Constants.Fonts.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Constants.Colors.primaryGreen, Constants.Colors.secondaryGreen],
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
                value: TimeFormatter.shared.formatTime(period.startDate, use24Hour: false),
                color: Constants.Colors.success
            )
            
            timeInfoItem(
                icon: "clock.badge.checkmark",
                title: "End Time", 
                value: TimeFormatter.shared.formatTime(period.endDate, use24Hour: false),
                color: Constants.Colors.warning
            )
            
            timeInfoItem(
                icon: "timer",
                title: "Duration",
                value: TimeFormatter.shared.formatDuration(period.duration),
                color: Constants.Colors.primaryGreen
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
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Text(value)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
        }
    }
    
}

// MARK: - Schedule Summary View

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
                .foregroundColor(Constants.Colors.textPrimary)
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
                        value: TimeFormatter.shared.formatTime(firstPeriod.startDate, use24Hour: false)
                    )
                    .id("first-time-false")
                    
                    summaryRow(
                        icon: "sunset",
                        title: "Last Period Ends",
                        value: TimeFormatter.shared.formatTime(lastPeriod.endDate, use24Hour: false)
                    )
                    .id("last-time-false")
                }
            }
        }
        .padding(20)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 20)
            
            Text(title)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.textPrimary)
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