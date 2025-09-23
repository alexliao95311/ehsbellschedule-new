//
//  MyLiveActivityManager.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 9/22/25.
//

import Foundation
import ActivityKit
import WidgetKit

@MainActor
class MyLiveActivityManager: ObservableObject {
    static let shared = MyLiveActivityManager()
    
    @Published var isLiveActivityActive = false
    @Published var currentActivity: Activity<MyLiveActivitiesAttributes>?
    
    private var updateTimer: Timer?
    
    private init() {
        updateLiveActivityStatus()
    }
    
    // MARK: - Live Activity Management
    
    func startLiveActivity() async {
        print("🚀 MyLiveActivityManager: Starting Live Activity...")
        
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("❌ Live Activities are not enabled")
            return
        }
        
        // Stop any existing activity
        await stopLiveActivity()
        
        // Get current schedule data
        let liveActivitiesData = MyLiveActivitiesDataProvider.shared.getLiveActivitiesData()
        let contentState = MyLiveActivitiesDataProvider.shared.createContentState(from: liveActivitiesData)
        
        let attributes = MyLiveActivitiesAttributes(schoolName: "EHS")
        
        do {
            let activity = try Activity<MyLiveActivitiesAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            isLiveActivityActive = true
            
            print("✅ Live Activity started successfully")
            print("   Activity ID: \(activity.id)")
            print("   Status: \(contentState.scheduleStatus)")
            print("   Is in class: \(contentState.isInClass)")
            print("   Time remaining: \(contentState.timeRemaining ?? 0)")
            
            // Set up automatic updates every second for real-time countdown
            setupRealTimeUpdates()
            
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
    
    func stopLiveActivity() async {
        print("🛑 MyLiveActivityManager: Stopping Live Activity...")
        
        // Stop the update timer
        updateTimer?.invalidate()
        updateTimer = nil
        
        guard let activity = currentActivity else {
            print("ℹ️ No active Live Activity to stop")
            return
        }
        
        let finalContentState = MyLiveActivitiesDataProvider.shared.createContentState(
            from: MyLiveActivitiesDataProvider.shared.getLiveActivitiesData()
        )
        
        await activity.end(.init(state: finalContentState, staleDate: nil), dismissalPolicy: .immediate)
        
        currentActivity = nil
        isLiveActivityActive = false
        
        print("✅ Live Activity stopped")
    }
    
    func updateLiveActivity() async {
        guard let activity = currentActivity else {
            print("ℹ️ No active Live Activity to update")
            return
        }
        
        let liveActivitiesData = MyLiveActivitiesDataProvider.shared.getLiveActivitiesData()
        let contentState = MyLiveActivitiesDataProvider.shared.createContentState(from: liveActivitiesData)
        
        await activity.update(.init(state: contentState, staleDate: nil))
        
        print("🔄 Live Activity updated")
        print("   Status: \(contentState.scheduleStatus)")
        print("   Time remaining: \(contentState.timeRemaining ?? 0)")
    }
    
    // MARK: - Helper Methods
    
    private func updateLiveActivityStatus() {
        // Check if there's an active Live Activity
        if let activities = Activity<MyLiveActivitiesAttributes>.activities.first {
            currentActivity = activities
            isLiveActivityActive = true
            print("✅ Found existing Live Activity: \(activities.id)")
            setupRealTimeUpdates()
        } else {
            currentActivity = nil
            isLiveActivityActive = false
            print("ℹ️ No active Live Activity found")
        }
    }
    
    private func setupRealTimeUpdates() {
        // Stop any existing timer
        updateTimer?.invalidate()
        
        // Update Live Activity every second for real-time countdown
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateLiveActivity()
            }
        }
        
        print("✅ Real-time updates started (every 1 second)")
    }
    
    // MARK: - Public Interface
    
    func toggleLiveActivity() async {
        if isLiveActivityActive {
            await stopLiveActivity()
        } else {
            await startLiveActivity()
        }
    }
    
    func refreshLiveActivity() async {
        if isLiveActivityActive {
            await updateLiveActivity()
        } else {
            await startLiveActivity()
        }
    }
    
    func forceUpdateLiveActivity() async {
        // Force an immediate update regardless of timer
        await updateLiveActivity()
    }
}

// MARK: - Live Activity Status Extensions

extension MyLiveActivityManager {
    var liveActivityStatusText: String {
        if isLiveActivityActive {
            return "Live Activity Active"
        } else {
            return "Live Activity Inactive"
        }
    }
    
    var liveActivityStatusColor: String {
        if isLiveActivityActive {
            return "green"
        } else {
            return "gray"
        }
    }
    
    var canStartLiveActivity: Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    var isUpdating: Bool {
        return updateTimer != nil
    }
}
