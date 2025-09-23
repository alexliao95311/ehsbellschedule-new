//
//  ContentView.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 8/10/25.
//

import SwiftUI
import UIKit
import ActivityKit

struct ContentView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var liveActivityManager = LiveActivityManager.shared
    @StateObject private var myLiveActivityManager = MyLiveActivityManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Schedule")
                }
                .tag(0)
            
            InformationView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Info")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .preferredColorScheme(preferences.isDarkMode ? .dark : .light)
        .tint(Constants.Colors.primaryGreen(preferences.isDarkMode))
        .onAppear {
            print("🚀 ContentView appeared - Main app is running!")
            setupInitialState()
            setupTabBarAppearance()
            
            // Set up frequent widget updates
            setupFrequentWidgetUpdates()
            
            // Set up Live Activity management
            setupLiveActivityManagement()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("📱 App became active - updating widget data")
            updateWidgetData()
            updateLiveActivityIfNeeded()
        }
        .onChange(of: selectedTab) { newValue in
            print("Tab changed to: \(newValue)")
            updateTabBarAppearance()
        }
        .onChange(of: preferences.isDarkMode) { _ in
            print("Dark mode changed, updating tab bar appearance")
            updateTabBarAppearance()
        }
        .id(preferences.isDarkMode) // Force refresh when dark mode changes
    }
    
    private func setupInitialState() {
        print("🔧 setupInitialState called")
        // Check notification authorization on app launch
        notificationService.checkAuthorizationStatus()
        
        // Setup widget data sharing
        print("📱 Setting up widget data sharing...")
        updateWidgetData()
        
        // Request notification permissions if not already requested
        if !notificationService.isAuthorized && preferences.notificationMinutesBefore > 0 {
            Task {
                await notificationService.requestAuthorization()
            }
        }
    }
    
    private func updateWidgetData() {
        print("🔄 ContentView: updateWidgetData() called")
        let calculator = ScheduleCalculator.shared
        let status = calculator.getScheduleStatus()
        
        print("📅 Schedule status: \(status)")
        
        // Check if it's a school day
        let isSchoolDay = calculator.isSchoolDay()
        print("🏫 Is school day: \(isSchoolDay)")
        
        let widgetData = createWidgetData(from: status)
        print("📱 Created widget data: \(widgetData.scheduleStatus)")
        print("   Current period: \(widgetData.currentPeriodName ?? "nil")")
        print("   Teacher: \(widgetData.currentPeriodTeacher ?? "nil")")
        print("   Room: \(widgetData.currentPeriodRoom ?? "nil")")
        print("   Next period: \(widgetData.nextPeriodName ?? "nil")")
        print("   Time remaining: \(widgetData.timeRemaining ?? 0)")
        
        DataPersistenceService.shared.saveWidgetData(widgetData)
        print("💾 Widget data saved via DataPersistenceService")
        
        // Also save Live Activities data
        saveLiveActivitiesData(from: widgetData)
    }
    
    private func createWidgetData(from status: ScheduleStatus) -> WidgetData {
        print("🔧 Creating widget data for status: \(status)")
        
        switch status {
        case .inClass(let period, let timeRemaining, let progress):
            let classInfo = preferences.getClassInfo(for: period)
            print("   📚 In class: \(classInfo.displayName), Teacher: \(classInfo.teacher), Room: \(classInfo.room)")
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
            print("   🚶 Passing period: Next class \(classInfo.displayName), Teacher: \(classInfo.teacher), Room: \(classInfo.room)")
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
            print("   🌅 Before school: Next class \(classInfo.displayName), Teacher: \(classInfo.teacher), Room: \(classInfo.room)")
            return WidgetData(
                nextPeriodName: classInfo.displayName,
                nextPeriodStartTime: nextPeriod.startDate,
                nextPeriodTeacher: classInfo.teacher.isEmpty ? nil : classInfo.teacher,
                nextPeriodRoom: classInfo.room.isEmpty ? nil : classInfo.room,
                scheduleStatus: "Before School",
                timeRemaining: timeUntilNext
            )
            
        case .afterSchool:
            print("   🌆 After school")
            return WidgetData(scheduleStatus: "After School")
            
        case .noSchool:
            print("   🏠 No school today")
            return WidgetData(scheduleStatus: "No School")
        }
    }
    
    private func setupTabBarAppearance() {
        updateTabBarAppearance()
    }
    
    private func updateTabBarAppearance() {
        print("Updating tab bar appearance for tab: \(selectedTab)")
        let appearance = UITabBarAppearance()
        
        // Configure appearance based on dark mode
        appearance.configureWithOpaqueBackground()
        if preferences.isDarkMode {
            appearance.backgroundColor = UIColor(Constants.Colors.darkCardBackground)
            
            // Configure normal state (unselected) - light gray for dark mode
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Constants.Colors.darkTextSecondary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Constants.Colors.darkTextSecondary)
            ]
            
            // Configure selected state - bright green for dark mode
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Constants.Colors.darkPrimaryGreen)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Constants.Colors.darkPrimaryGreen)
            ]
        } else {
            appearance.backgroundColor = UIColor(Constants.Colors.lightCardBackground)
            
            // Configure normal state (unselected) - dark gray for light mode
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Constants.Colors.lightTextSecondary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Constants.Colors.lightTextSecondary)
            ]
            
            // Configure selected state - dark green for light mode
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Constants.Colors.lightPrimaryGreen)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Constants.Colors.lightPrimaryGreen)
            ]
        }
        
        // Apply appearance globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Force update the current tab bar immediately
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController?.children.first as? UITabBarController {
                    tabBarController.tabBar.standardAppearance = appearance
                    tabBarController.tabBar.scrollEdgeAppearance = appearance
                    tabBarController.tabBar.setNeedsLayout()
                    tabBarController.tabBar.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Widget Update Management
    
    private func setupFrequentWidgetUpdates() {
        // Update widget data every 5 seconds to ensure it stays current
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            print("🔄 Frequent widget update triggered")
            self.updateWidgetData()
        }
    }
    
    // MARK: - Live Activity Management
    
    private func setupLiveActivityManagement() {
        print("🎯 Setting up Live Activity management...")
        
        // Check if Live Activities are available and should be started
        let calculator = ScheduleCalculator.shared
        let status = calculator.getScheduleStatus()
        
        // Start Live Activity if we're in a school period or passing period
        let shouldStartLiveActivity = shouldStartLiveActivityForStatus(status)
        
        if shouldStartLiveActivity && liveActivityManager.canStartLiveActivity {
            Task {
                await liveActivityManager.startLiveActivity()
                print("✅ Live Activity started automatically")
            }
        } else {
            print("ℹ️ Live Activity not started - status: \(status), can start: \(liveActivityManager.canStartLiveActivity)")
        }
        
        // Also start the new countdown Live Activity
        if shouldStartLiveActivity && myLiveActivityManager.canStartLiveActivity {
            Task {
                await myLiveActivityManager.startLiveActivity()
                print("✅ Countdown Live Activity started automatically")
            }
        } else {
            print("ℹ️ Countdown Live Activity not started - status: \(status), can start: \(myLiveActivityManager.canStartLiveActivity)")
        }
    }
    
    private func shouldStartLiveActivityForStatus(_ status: ScheduleStatus) -> Bool {
        switch status {
        case .inClass, .passingPeriod:
            return true
        case .beforeSchool, .afterSchool, .noSchool:
            return false
        }
    }
    
    private func updateLiveActivityIfNeeded() {
        guard liveActivityManager.isLiveActivityActive else { return }
        
        Task {
            await liveActivityManager.updateLiveActivity()
        }
        
        // Also update the countdown Live Activity
        if myLiveActivityManager.isLiveActivityActive {
            Task {
                await myLiveActivityManager.forceUpdateLiveActivity()
            }
        }
    }
    
    private func saveLiveActivitiesData(from widgetData: WidgetData) {
        print("💾 Saving Live Activities data...")
        
        let liveActivitiesData = MyLiveActivitiesData(
            currentClassName: widgetData.currentPeriodName,
            currentClassTeacher: widgetData.currentPeriodTeacher,
            currentClassRoom: widgetData.currentPeriodRoom,
            classStartTime: widgetData.currentPeriodEndTime?.addingTimeInterval(-(widgetData.timeRemaining ?? 0)),
            classEndTime: widgetData.currentPeriodEndTime,
            timeRemaining: widgetData.timeRemaining,
            progress: widgetData.progress,
            scheduleStatus: widgetData.scheduleStatus,
            isInClass: widgetData.currentPeriodName != nil && widgetData.timeRemaining != nil && widgetData.timeRemaining! > 0,
            nextClassName: widgetData.nextPeriodName,
            nextClassTeacher: widgetData.nextPeriodTeacher,
            nextClassRoom: widgetData.nextPeriodRoom,
            nextClassStartTime: widgetData.nextPeriodStartTime
        )
        
        MyLiveActivitiesDataProvider.shared.saveLiveActivitiesData(liveActivitiesData)
        print("✅ Live Activities data saved")
        
        // Update the Live Activity if it's active
        if myLiveActivityManager.isLiveActivityActive {
            Task {
                await myLiveActivityManager.forceUpdateLiveActivity()
            }
        }
    }
}

#Preview {
    ContentView()
}
