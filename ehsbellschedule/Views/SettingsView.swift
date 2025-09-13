import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingNotificationAlert = false
    @State private var showingResetAlert = false
    @State private var showingCustomClassNames = false
    @State private var testNotificationSent = false
    @State private var showingTestResult = false
    @State private var testResultMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Moved customization section to the top since it's most important
                customizationSection
                displaySettingsSection
                scheduleSettingsSection
                notificationSettingsSection
                aboutSection
            }
            .listSectionSeparatorTint(Constants.Colors.textSecondary(preferences.isDarkMode))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Constants.Colors.backgroundGray(preferences.isDarkMode))
        }
        .background(Constants.Colors.backgroundGray(preferences.isDarkMode))
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingCustomClassNames) {
            CustomClassNamesView()
        }
        .alert("Enable Notifications", isPresented: $showingNotificationAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To receive class ending notifications, please enable notifications for this app in Settings.")
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all settings to their default values. This cannot be undone.")
        }
        .alert("Test Notification", isPresented: $showingTestResult) {
            Button("OK") { }
        } message: {
            Text(testResultMessage)
        }
        .id(preferences.isDarkMode) // Force refresh when dark mode changes
    }
    
    // MARK: - Customization Section (moved to top - most important)
    
    private var customizationSection: some View {
        Section("Customization") {
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
        }
        .listRowBackground(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - Display Settings Section
    
    private var displaySettingsSection: some View {
        Section("Display") {
            Toggle("Dark Mode", isOn: $preferences.isDarkMode)
                .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            HStack {
                Image(systemName: preferences.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text(preferences.isDarkMode ? "Dark theme with green accents" : "Light theme with green accents")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
            
            Toggle("24-Hour Time Format", isOn: $preferences.use24HourFormat)
                .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time Format")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text(preferences.use24HourFormat ? "15:30" : "3:30 PM")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
        }
        .listRowBackground(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - Schedule Settings Section
    
    private var scheduleSettingsSection: some View {
        Section("Schedule") {
            Toggle("Show Period 0", isOn: $preferences.showPeriod0)
                .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            Toggle("Show Period 7", isOn: $preferences.showPeriod7)
                .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Visible Periods")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text("Choose which periods appear in your schedule")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
        }
        .listRowBackground(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - Notification Settings Section
    
    private var notificationSettingsSection: some View {
        Section("Notifications") {
            notificationToggleRow
            
            if notificationService.isAuthorized {
                notificationTimingRow
                passingPeriodToggleRow
                testNotificationRow
            }
        }
    }
    
    private var notificationToggleRow: some View {
        HStack {
            Image(systemName: notificationService.isAuthorized ? "bell.fill" : "bell.slash")
                .foregroundColor(notificationService.isAuthorized ? Constants.Colors.primaryGreen(preferences.isDarkMode) : Constants.Colors.textSecondary(preferences.isDarkMode))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Class Ending Notifications")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                
                Text(notificationService.isAuthorized ? "Enabled" : "Disabled")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(notificationService.isAuthorized ? Constants.Colors.success : Constants.Colors.textSecondary(preferences.isDarkMode))
            }
            
            Spacer()
            
            if !notificationService.isAuthorized {
                Button("Enable") {
                    Task {
                        let granted = await notificationService.requestAuthorization()
                        if !granted {
                            showingNotificationAlert = true
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
            }
        }
    }
    
    private var notificationTimingRow: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Notification Timing")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                
                Text("\(preferences.notificationMinutesBefore) minute\(preferences.notificationMinutesBefore == 1 ? "" : "s") before class ends")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
            }
            
            Spacer()
            
            Picker("Minutes", selection: $preferences.notificationMinutesBefore) {
                ForEach([1, 2, 3, 5, 10], id: \.self) { minutes in
                    Text("\(minutes)m").tag(minutes)
                }
            }
            .pickerStyle(.menu)
            .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
        }
    }
    
    private var passingPeriodToggleRow: some View {
        Toggle("Passing Period Notifications", isOn: $preferences.enablePassingPeriodNotifications)
            .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
    }
    
    private var testNotificationRow: some View {
        Button(action: {
            Task {
                // First check authorization
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                
                if settings.authorizationStatus != .authorized {
                    await MainActor.run {
                        testResultMessage = "Notifications not authorized. Please enable in Settings app."
                        showingTestResult = true
                    }
                    return
                }
                
                await notificationService.sendTestNotification()
                
                await MainActor.run {
                    testNotificationSent = true
                    testResultMessage = "Test notification sent! Check your notification center in 2 seconds."
                    showingTestResult = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    testNotificationSent = false
                }
            }
        }) {
            HStack {
                Image(systemName: testNotificationSent ? "checkmark.circle.fill" : "bell.badge")
                    .foregroundColor(testNotificationSent ? Constants.Colors.success : Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Test Notification")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text(testNotificationSent ? "Test notification sent!" : "Send a test notification")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(testNotificationSent ? Constants.Colors.success : Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
        }
        .disabled(testNotificationSent)
        .listRowBackground(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("EHS Schedule")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text("Version 2.2 - FIXED SCHEDULE SWITCHING")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "c.circle")
                    .foregroundColor(Constants.Colors.primaryGreen(preferences.isDarkMode))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Copyright © 2025 EHS Schedule Team")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary(preferences.isDarkMode))
                    
                    Text("Made by Justin Fu, Alex Liao, Arnav Kakani, Sanjana Gowda, and Shely Jain")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary(preferences.isDarkMode))
                }
                
                Spacer()
            }
            
            Button("Reset All Settings", role: .destructive) {
                showingResetAlert = true
            }
        }
        .listRowBackground(Constants.Colors.cardBackground(preferences.isDarkMode))
    }
    
    // MARK: - Helper Methods
    
    private func resetAllSettings() {
        preferences.resetToDefaults()
        notificationService.clearAllNotifications()
        
        // Show a brief success message
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}
