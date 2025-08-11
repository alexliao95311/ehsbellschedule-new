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
                displaySettingsSection
                scheduleSettingsSection
                notificationSettingsSection
                customizationSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
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
    }
    
    // MARK: - Display Settings Section
    
    private var displaySettingsSection: some View {
        Section("Display") {
            Toggle("24-Hour Time Format", isOn: $preferences.use24HourFormat)
                .tint(Constants.Colors.primaryBlue)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time Format")
                        .font(Constants.Fonts.body)
                    
                    Text(preferences.use24HourFormat ? "15:30" : "3:30 PM")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Schedule Settings Section
    
    private var scheduleSettingsSection: some View {
        Section("Schedule") {
            Toggle("Show Period 0", isOn: $preferences.showPeriod0)
                .tint(Constants.Colors.primaryBlue)
            
            Toggle("Show Period 7", isOn: $preferences.showPeriod7)
                .tint(Constants.Colors.primaryBlue)
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Visible Periods")
                        .font(Constants.Fonts.body)
                    
                    Text("Choose which periods appear in your schedule")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
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
                .foregroundColor(notificationService.isAuthorized ? Constants.Colors.primaryBlue : Constants.Colors.textSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Class Ending Notifications")
                    .font(Constants.Fonts.body)
                
                Text(notificationService.isAuthorized ? "Enabled" : "Disabled")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(notificationService.isAuthorized ? Constants.Colors.success : Constants.Colors.textSecondary)
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
                .tint(Constants.Colors.primaryBlue)
            }
        }
    }
    
    private var notificationTimingRow: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Notification Timing")
                    .font(Constants.Fonts.body)
                
                Text("\(preferences.notificationMinutesBefore) minute\(preferences.notificationMinutesBefore == 1 ? "" : "s") before class ends")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            Picker("Minutes", selection: $preferences.notificationMinutesBefore) {
                ForEach([1, 2, 3, 5, 10], id: \.self) { minutes in
                    Text("\(minutes)m").tag(minutes)
                }
            }
            .pickerStyle(.menu)
            .tint(Constants.Colors.primaryBlue)
        }
    }
    
    private var passingPeriodToggleRow: some View {
        Toggle("Passing Period Notifications", isOn: $preferences.enablePassingPeriodNotifications)
            .tint(Constants.Colors.primaryBlue)
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
                    .foregroundColor(testNotificationSent ? Constants.Colors.success : Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Test Notification")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(testNotificationSent ? "Test notification sent!" : "Send a test notification")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(testNotificationSent ? Constants.Colors.success : Constants.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
        .disabled(testNotificationSent)
    }
    
    // MARK: - Customization Section
    
    private var customizationSection: some View {
        Section("Customization") {
            Button(action: {
                showingCustomClassNames = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Custom Class Names")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Text("Personalize your class names")
                            .font(Constants.Fonts.caption)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("EHS Bell Schedule")
                        .font(Constants.Fonts.body)
                    
                    Text("Version 1.0.0")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
            }
            
            Button("Reset All Settings", role: .destructive) {
                showingResetAlert = true
            }
        }
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