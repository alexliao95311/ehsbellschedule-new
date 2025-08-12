import SwiftUI

struct ScheduleView: View {
    @StateObject private var scheduleViewModel = ScheduleViewModel()
    @ObservedObject private var preferences = UserPreferences.shared
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 20) {
                headerView
                
                mainContentView
                
                Spacer()
                
                upcomingPeriodsView
            }
            .padding(.horizontal, Constants.Layout.padding)
            .padding(.top, 60)
        }
        .id(preferences.use24HourFormat) // Force refresh when format changes
        .onAppear {
            scheduleViewModel.startTimer()
        }
        .onDisappear {
            scheduleViewModel.stopTimer()
        }
    }
    
    // MARK: - Background View
    
    @ViewBuilder
    private var backgroundView: some View {
        if let backgroundImageName = preferences.backgroundImageName {
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                )
        } else {
            Constants.Colors.backgroundGray.ignoresSafeArea()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text(scheduleViewModel.currentDateString)
                .font(Constants.Fonts.headline)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Main Content View
    
    @ViewBuilder
    private var mainContentView: some View {
        switch scheduleViewModel.scheduleStatus {
        case .noSchool:
            noSchoolView
            
        case .beforeSchool(let nextPeriod, let timeUntilNext):
            beforeSchoolView(nextPeriod: nextPeriod, timeUntilNext: timeUntilNext)
            
        case .inClass(let period, let timeRemaining, let progress):
            inClassView(period: period, timeRemaining: timeRemaining, progress: progress)
            
        case .passingPeriod(let nextPeriod, let timeUntilNext):
            passingPeriodView(nextPeriod: nextPeriod, timeUntilNext: timeUntilNext)
            
        case .afterSchool:
            afterSchoolView
        }
    }
    
    // MARK: - Status Views
    
    private var noSchoolView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.primaryGreen)
            
            Text("No School Today")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.bold)
            
            Text("Enjoy your weekend!")
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.8))
        }
        .padding(.vertical, 40)
    }
    
    private func beforeSchoolView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "sunrise")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.primaryGreen)
            
            Text("School starts in")
                .font(Constants.Fonts.headline)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Next Period:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
                
                let nextClassInfo = preferences.getClassInfo(for: nextPeriod)
                
                Text(nextClassInfo.displayName)
                    .font(Constants.Fonts.title)
                    .foregroundColor(Constants.Colors.primaryGreen)
                    .fontWeight(.semibold)
                
                if nextClassInfo.hasDetails {
                    Text(nextClassInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
                }
                
                Text(TimeFormatter.shared.formatTimeRange(
                    start: nextPeriod.startDate,
                    end: nextPeriod.endDate,
                    use24Hour: preferences.use24HourFormat
                ))
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.8))
            }
        }
        .padding(.vertical, 20)
    }
    
    private func inClassView(period: Period, timeRemaining: TimeInterval, progress: Double) -> some View {
        VStack(spacing: 24) {
            // Current class name
            VStack(spacing: 8) {
                let classInfo = preferences.getClassInfo(for: period)
                
                Text(classInfo.displayName)
                    .font(Constants.Fonts.largeTitle)
                    .foregroundColor(Constants.Colors.primaryGreen)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if classInfo.hasDetails {
                    Text(classInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryGreen.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Countdown timer with circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Constants.Colors.primaryGreen.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Constants.Colors.primaryGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(Constants.Animation.smooth, value: progress)
                
                // Time remaining
                VStack(spacing: 4) {
                    Text(TimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(Constants.Fonts.countdown)
                        .foregroundColor(Constants.Colors.primaryGreen)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    
                    Text("remaining")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
                }
            }
            
            // Period time range
            Text(TimeFormatter.shared.formatTimeRange(
                start: period.startDate,
                end: period.endDate,
                use24Hour: preferences.use24HourFormat
            ))
            .font(Constants.Fonts.headline)
            .foregroundColor(Constants.Colors.primaryGreen.opacity(0.9))
        }
    }
    
    private func passingPeriodView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.primaryGreen)
            
            Text("Passing Period")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.bold)
            
            Text("Next class in")
                .font(Constants.Fonts.headline)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Up Next:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
                
                let nextClassInfo = preferences.getClassInfo(for: nextPeriod)
                
                Text(nextClassInfo.displayName)
                    .font(Constants.Fonts.title)
                    .foregroundColor(Constants.Colors.primaryGreen)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if nextClassInfo.hasDetails {
                    Text(nextClassInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var afterSchoolView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sunset")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.primaryGreen)
            
            Text("School's Out!")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(Constants.Colors.primaryGreen)
                .fontWeight(.bold)
            
            Text("Have a great rest of your day!")
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Upcoming Periods View
    
    @ViewBuilder
    private var upcomingPeriodsView: some View {
        if !scheduleViewModel.upcomingPeriods.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming Classes")
                    .font(Constants.Fonts.headline)
                    .foregroundColor(Constants.Colors.primaryGreen)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(scheduleViewModel.upcomingPeriods) { period in
                            upcomingPeriodRow(period: period)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .frame(maxHeight: 300) // Increased height to show more classes
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.primaryGreen.opacity(0.15))
            )
            .padding(.bottom, 40) // Reduced bottom padding
        }
    }
    
    private func upcomingPeriodRow(period: Period) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                let classInfo = preferences.getClassInfo(for: period)
                
                Text(classInfo.displayName)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryGreen)
                    .fontWeight(.medium)
                
                if classInfo.hasDetails {
                    Text(classInfo.detailsText)
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.primaryGreen.opacity(0.6))
                }
                
                Text(period.displayName)
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.primaryGreen.opacity(0.7))
            }
            
            Spacer()
            
            Text(TimeFormatter.shared.formatTime(period.startDate, use24Hour: preferences.use24HourFormat))
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryGreen.opacity(0.9))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Constants.Colors.primaryGreen.opacity(0.1))
        )
    }
}