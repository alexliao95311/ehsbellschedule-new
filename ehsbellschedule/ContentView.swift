//
//  ContentView.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 8/10/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var preferences = UserPreferences()
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Schedule")
                }
            
            InformationView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Info")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .tint(Constants.Colors.primaryGreen)
        .onAppear {
            setupInitialState()
            setupTabBarAppearance()
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
        let calculator = ScheduleCalculator.shared
        let status = calculator.getScheduleStatus()
        
        let widgetData = createWidgetData(from: status)
        DataPersistenceService.shared.saveWidgetData(widgetData)
    }
    
    private func createWidgetData(from status: ScheduleStatus) -> WidgetData {
        switch status {
        case .inClass(let period, let timeRemaining, let progress):
            let className = preferences.getClassName(for: period)
            return WidgetData(
                currentPeriodName: className,
                currentPeriodEndTime: period.endDate,
                scheduleStatus: "In Class",
                timeRemaining: timeRemaining,
                progress: progress
            )
            
        case .passingPeriod(let nextPeriod, let timeUntilNext):
            let nextClassName = preferences.getClassName(for: nextPeriod)
            return WidgetData(
                nextPeriodName: nextClassName,
                nextPeriodStartTime: nextPeriod.startDate,
                scheduleStatus: "Passing Period",
                timeRemaining: timeUntilNext
            )
            
        case .beforeSchool(let nextPeriod, let timeUntilNext):
            let nextClassName = preferences.getClassName(for: nextPeriod)
            return WidgetData(
                nextPeriodName: nextClassName,
                nextPeriodStartTime: nextPeriod.startDate,
                scheduleStatus: "Before School",
                timeRemaining: timeUntilNext
            )
            
        case .afterSchool:
            return WidgetData(scheduleStatus: "After School")
            
        case .noSchool:
            return WidgetData(scheduleStatus: "No School")
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Configure background with green gradient effect
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Constants.Colors.primaryGreen)
        
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
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
