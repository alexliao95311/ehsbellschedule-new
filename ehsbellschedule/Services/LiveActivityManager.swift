//
//  LiveActivityManager.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 8/10/25.
//

import Foundation
import ActivityKit
import WidgetKit

// MARK: - Live Activity Attributes (matching bellschedulewidget)

struct BellScheduleActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentPeriodName: String?
        var currentPeriodTeacher: String?
        var currentPeriodRoom: String?
        var currentPeriodEndTime: Date?
        var timeRemaining: TimeInterval?
        var nextPeriodName: String?
        var nextPeriodTeacher: String?
        var nextPeriodRoom: String?
        var nextPeriodStartTime: Date?
        var scheduleStatus: String
        var progress: Double?
        var isInClass: Bool
        var lastUpdated: Date
    }

    // Fixed properties
    var schoolName: String = "EHS"
}

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published var isLiveActivityActive = false
    @Published var currentActivity: Activity<BellScheduleActivityAttributes>?
    
    private init() {
        updateLiveActivityStatus()
    }
    
    // MARK: - Live Activity Management
    
    func startLiveActivity() async {
        print("🚀 LiveActivityManager: Starting Live Activity...")
        
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("❌ Live Activities are not enabled")
            return
        }
        
        // Stop any existing activity
        await stopLiveActivity()
        
        // Get current schedule data
        let widgetData = DataPersistenceService.shared.loadWidgetData() ?? WidgetData(scheduleStatus: "No Data")
        let contentState = createContentState(from: widgetData)
        
        let attributes = BellScheduleActivityAttributes(schoolName: "EHS")
        
        do {
            let activity = try Activity<BellScheduleActivityAttributes>.request(
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
            
            // Set up automatic updates
            setupLiveActivityUpdates()
            
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            
            // Provide specific error guidance
            if error.localizedDescription.contains("unsupportedTarget") {
                print("💡 Troubleshooting tips:")
                print("   - Make sure you're running on a physical device (not simulator)")
                print("   - Check that Live Activities are enabled in Settings → Face ID & Passcode")
                print("   - Ensure your device supports Live Activities (iOS 16.1+)")
                print("   - Try enabling Live Activities in Settings → [App Name]")
            }
        }
    }
    
    func stopLiveActivity() async {
        print("🛑 LiveActivityManager: Stopping Live Activity...")
        
        guard let activity = currentActivity else {
            print("ℹ️ No active Live Activity to stop")
            return
        }
        
        let finalContentState = createContentState(from: DataPersistenceService.shared.loadWidgetData() ?? WidgetData(scheduleStatus: "No Data"))
        
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
        
        let widgetData = DataPersistenceService.shared.loadWidgetData() ?? WidgetData(scheduleStatus: "No Data")
        let contentState = createContentState(from: widgetData)
        
        await activity.update(.init(state: contentState, staleDate: nil))
        
        print("🔄 Live Activity updated")
        print("   Status: \(contentState.scheduleStatus)")
        print("   Time remaining: \(contentState.timeRemaining ?? 0)")
    }
    
    // MARK: - Helper Methods
    
    private func createContentState(from widgetData: WidgetData) -> BellScheduleActivityAttributes.ContentState {
        let isInClass = widgetData.currentPeriodName != nil && widgetData.timeRemaining != nil && widgetData.timeRemaining! > 0
        
        return BellScheduleActivityAttributes.ContentState(
            currentPeriodName: widgetData.currentPeriodName,
            currentPeriodTeacher: widgetData.currentPeriodTeacher,
            currentPeriodRoom: widgetData.currentPeriodRoom,
            currentPeriodEndTime: widgetData.currentPeriodEndTime,
            timeRemaining: widgetData.timeRemaining,
            nextPeriodName: widgetData.nextPeriodName,
            nextPeriodTeacher: widgetData.nextPeriodTeacher,
            nextPeriodRoom: widgetData.nextPeriodRoom,
            nextPeriodStartTime: widgetData.nextPeriodStartTime,
            scheduleStatus: widgetData.scheduleStatus,
            progress: widgetData.progress,
            isInClass: isInClass,
            lastUpdated: widgetData.lastUpdated
        )
    }
    
    private func updateLiveActivityStatus() {
        // Check if there's an active Live Activity
        if let activities = Activity<BellScheduleActivityAttributes>.activities.first {
            currentActivity = activities
            isLiveActivityActive = true
            print("✅ Found existing Live Activity: \(activities.id)")
        } else {
            currentActivity = nil
            isLiveActivityActive = false
            print("ℹ️ No active Live Activity found")
        }
    }
    
    private func setupLiveActivityUpdates() {
        // Update Live Activity every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateLiveActivity()
            }
        }
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
}

// MARK: - Live Activity Status Extensions

extension LiveActivityManager {
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
}
