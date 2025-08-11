import SwiftUI

struct ScheduleView: View {
    @StateObject private var scheduleViewModel = ScheduleViewModel()
    @StateObject private var preferences = UserPreferences()
    
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
            .padding(.top, 20)
        }
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
            LinearGradient(
                colors: [Constants.Colors.primaryGreen, Constants.Colors.secondaryGreen, Constants.Colors.accentGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(scheduleViewModel.currentScheduleType)
                    .font(Constants.Fonts.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("•")
                    .font(Constants.Fonts.headline)
                    .foregroundColor(.white.opacity(0.5))
                
                Text(scheduleViewModel.currentScheduleAbbreviation)
                    .font(Constants.Fonts.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(scheduleViewModel.currentDateString)
                .font(Constants.Fonts.body)
                .foregroundColor(.white.opacity(0.7))
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
                .foregroundColor(.white)
            
            Text("No School Today")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            Text("Enjoy your weekend!")
                .font(Constants.Fonts.body)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 40)
    }
    
    private func beforeSchoolView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "sunrise")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("School starts in")
                .font(Constants.Fonts.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Next Period:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(preferences.getClassName(for: nextPeriod))
                    .font(Constants.Fonts.title)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Text(TimeFormatter.shared.formatTimeRange(
                    start: nextPeriod.startDate,
                    end: nextPeriod.endDate,
                    use24Hour: preferences.use24HourFormat
                ))
                .font(Constants.Fonts.body)
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 20)
    }
    
    private func inClassView(period: Period, timeRemaining: TimeInterval, progress: Double) -> some View {
        VStack(spacing: 24) {
            // Current class name
            VStack(spacing: 8) {
                Text("Current Class")
                    .font(Constants.Fonts.body)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(preferences.getClassName(for: period))
                    .font(Constants.Fonts.largeTitle)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            // Countdown timer with circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(Constants.Animation.smooth, value: progress)
                
                // Time remaining
                VStack(spacing: 4) {
                    Text(TimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(Constants.Fonts.countdown)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    
                    Text("remaining")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Period time range
            Text(TimeFormatter.shared.formatTimeRange(
                start: period.startDate,
                end: period.endDate,
                use24Hour: preferences.use24HourFormat
            ))
            .font(Constants.Fonts.headline)
            .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private func passingPeriodView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("Passing Period")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            Text("Next class in")
                .font(Constants.Fonts.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Up Next:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(preferences.getClassName(for: nextPeriod))
                    .font(Constants.Fonts.title)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var afterSchoolView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sunset")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("School's Out!")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            Text("Have a great rest of your day!")
                .font(Constants.Fonts.body)
                .foregroundColor(.white.opacity(0.8))
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
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                LazyVStack(spacing: 8) {
                    ForEach(scheduleViewModel.upcomingPeriods.prefix(3)) { period in
                        upcomingPeriodRow(period: period)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Color.white.opacity(0.15))
            )
            .padding(.bottom, 20)
        }
    }
    
    private func upcomingPeriodRow(period: Period) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(preferences.getClassName(for: period))
                    .font(Constants.Fonts.body)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                Text("Period \(period.number)")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(TimeFormatter.shared.formatTime(period.startDate, use24Hour: preferences.use24HourFormat))
                .font(Constants.Fonts.body)
                .foregroundColor(.white.opacity(0.9))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}