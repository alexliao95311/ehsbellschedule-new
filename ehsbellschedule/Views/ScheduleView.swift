import SwiftUI

struct ScheduleView: View {
    @StateObject private var scheduleViewModel = ScheduleViewModel()
    @ObservedObject private var preferences = UserPreferences.shared
    @State private var showingCustomClassNames = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content in a ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        mainContentView
                        upcomingPeriodsView
                    }
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Add padding for footer
                }
                .background(backgroundView)
                
                // Footer section (only show if no custom class names exist)
                if !preferences.hasAnyCustomClassNames() {
                    footerView
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingCustomClassNames) {
            NavigationView {
                VStack {
                    // Custom header with X button
                    HStack {
                        Text("Custom Class Names")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                        
                        Spacer()
                        
                        Button(action: {
                            showingCustomClassNames = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .background(Constants.Colors.backgroundGray(preferences.isDarkMode))
                    
                    Divider()
                        .background(Constants.Colors.textSecondary(preferences.isDarkMode))
                    
                    // The actual CustomClassNamesView content
                    CustomClassNamesView(onDismiss: {
                        showingCustomClassNames = false
                    })
                        .navigationBarHidden(true)
                }
                .background(Constants.Colors.backgroundGray(preferences.isDarkMode))
            }
            .background(Constants.Colors.backgroundGray(preferences.isDarkMode))
            .presentationDetents([.medium, .large])
        }
        .id(preferences.use24HourFormat) // Force refresh when format changes
        .id(preferences.isDarkMode) // Force refresh when dark mode changes
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
            Constants.Colors.backgroundGray(preferences.isDarkMode).ignoresSafeArea()
        }
    }
    
    // MARK: - Footer View (matching SettingsView style)
    
    private var footerView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Constants.Colors.textSecondary(preferences.isDarkMode))
            
            HStack {
                Button(action: {
                    showingCustomClassNames = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Custom Class Names")
                                .font(Constants.Fonts.body)
                                .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                            
                            Text("Personalize your class names")
                                .font(Constants.Fonts.caption)
                                .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Constants.Colors.cardBackground(preferences.isDarkMode))
        }
        .background(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text(scheduleViewModel.currentDateString)
                .font(Constants.Fonts.headline)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
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
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            Text("No School Today")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                .fontWeight(.bold)
            
            Text("Enjoy your weekend!")
                .font(Constants.Fonts.body)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.8))
        }
        .padding(.vertical, 40)
    }
    
    private func beforeSchoolView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "sunrise")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            Text("School starts in")
                .font(Constants.Fonts.headline)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Next Period:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
                
                let nextClassInfo = preferences.getClassInfo(for: nextPeriod)
                
                Text(nextClassInfo.displayName)
                    .font(Constants.Fonts.title)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .fontWeight(.semibold)
                
                if nextClassInfo.hasDetails {
                    Text(nextClassInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
                }
                
                Text(TimeFormatter.shared.formatTimeRange(
                    start: nextPeriod.startDate,
                    end: nextPeriod.endDate,
                    use24Hour: preferences.use24HourFormat
                ))
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.8))
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
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if classInfo.hasDetails {
                    Text(classInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Countdown timer with circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Constants.Colors.primaryGreen(preferences.isDarkMode), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(Constants.Animation.smooth, value: progress)
                
                // Time remaining
                VStack(spacing: 4) {
                    Text(TimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(Constants.Fonts.countdown)
                        .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                        .fontWeight(.bold)
                        .monospacedDigit()
                    
                    Text("remaining")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
                }
            }
            
            // Period time range
            Text(TimeFormatter.shared.formatTimeRange(
                start: period.startDate,
                end: period.endDate,
                use24Hour: preferences.use24HourFormat
            ))
            .font(Constants.Fonts.headline)
            .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.9))
        }
    }
    
    private func passingPeriodView(nextPeriod: Period, timeUntilNext: TimeInterval) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            Text("Passing Period")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                .fontWeight(.bold)
            
            Text("Next class in")
                .font(Constants.Fonts.headline)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.9))
            
            Text(TimeFormatter.shared.formatCountdown(timeUntilNext))
                .font(Constants.Fonts.countdown)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                .fontWeight(.bold)
                .monospacedDigit()
            
            VStack(spacing: 4) {
                Text("Up Next:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
                
                let nextClassInfo = preferences.getClassInfo(for: nextPeriod)
                
                Text(nextClassInfo.displayName)
                    .font(Constants.Fonts.title)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if nextClassInfo.hasDetails {
                    Text(nextClassInfo.detailsText)
                        .font(Constants.Fonts.body)
                        .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
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
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            Text("School's Out!")
                .font(Constants.Fonts.largeTitle)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                .fontWeight(.bold)
            
            Text("Have a great rest of your day!")
                .font(Constants.Fonts.body)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.8))
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
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                LazyVStack(spacing: 8) {
                    ForEach(scheduleViewModel.upcomingPeriods) { period in
                        upcomingPeriodRow(period: period)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.15))
            )
        }
    }
    
    private func upcomingPeriodRow(period: Period) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                let classInfo = preferences.getClassInfo(for: period)
                
                Text(classInfo.displayName)
                    .font(Constants.Fonts.body)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .fontWeight(.medium)
                
                if classInfo.hasDetails {
                    Text(classInfo.detailsText)
                        .font(Constants.Fonts.caption)
                        .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.6))
                }
                
                Text(period.displayName)
                    .font(Constants.Fonts.caption)
                    .foregroundColor(preferences.isDarkMode ? Constants.Colors.textSecondary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.7))
            }
            
            Spacer()
            
            Text(TimeFormatter.shared.formatTime(period.startDate, use24Hour: preferences.use24HourFormat))
                .font(Constants.Fonts.body)
                .foregroundColor(preferences.isDarkMode ? Constants.Colors.textPrimary(preferences.isDarkMode) : Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.9))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Constants.Colors.primaryGreen(preferences.isDarkMode).opacity(0.1))
        )
    }
}
