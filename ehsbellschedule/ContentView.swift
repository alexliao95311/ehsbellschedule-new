//
//  ContentView.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 8/10/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @StateObject private var notificationService = NotificationService.shared
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
        .tint(Constants.Colors.primaryGreen)
        .onAppear {
            setupInitialState()
            setupTabBarAppearance()
        }
        .onChange(of: selectedTab) { newValue in
            print("Tab changed to: \(newValue)")
            updateTabBarAppearance()
        }
    }
    
    private func setupInitialState() {
        // Check notification authorization on app launch
        notificationService.checkAuthorizationStatus()
        
        // Setup widget data sharing
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
        
        if selectedTab == 0 {
            // Schedule tab - Green background with white text/icons
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Constants.Colors.secondaryGreen)
            
            // Configure normal state (unselected) - white for contrast against green
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            
            // Configure selected state - bright white for active state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        } else {
            // Info and Settings tabs - White background with black text/icons
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            
            // Configure normal state (unselected) - dark gray
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black.withAlphaComponent(0.6)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.black.withAlphaComponent(0.6)
            ]
            
            // Configure selected state - black for active state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.black
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
}

#Preview {
    ContentView()
}
