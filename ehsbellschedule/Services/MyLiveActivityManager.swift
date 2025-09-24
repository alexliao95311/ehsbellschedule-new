//
//  MyLiveActivityManager.swift
//  ehsbellschedule
//
//  Created by Alex Liao on 9/22/25.
//

import Foundation
import ActivityKit
import WidgetKit

// MARK: - Live Activity Attributes (matching widget extension)

struct MyLiveActivitiesAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Current class information
        var currentClassName: String?
        var currentClassTeacher: String?
        var currentClassRoom: String?
        var classStartTime: Date?
        var classEndTime: Date?
        var timeRemaining: TimeInterval?
        var progress: Double?
        var scheduleStatus: String
        var isInClass: Bool
        var lastUpdated: Date
        
        // Next class information
        var nextClassName: String?
        var nextClassTeacher: String?
        var nextClassRoom: String?
        var nextClassStartTime: Date?
    }

    // Fixed non-changing properties about your activity go here!
    var schoolName: String
}

// MARK: - Data Models

struct MyLiveActivitiesData: Codable {
    let currentClassName: String?
    let currentClassTeacher: String?
    let currentClassRoom: String?
    let classStartTime: Date?
    let classEndTime: Date?
    let timeRemaining: TimeInterval?
    let progress: Double?
    let scheduleStatus: String
    let isInClass: Bool
    let lastUpdated: Date
    
    // Next class information
    let nextClassName: String?
    let nextClassTeacher: String?
    let nextClassRoom: String?
    let nextClassStartTime: Date?
    
    init(
        currentClassName: String? = nil,
        currentClassTeacher: String? = nil,
        currentClassRoom: String? = nil,
        classStartTime: Date? = nil,
        classEndTime: Date? = nil,
        timeRemaining: TimeInterval? = nil,
        progress: Double? = nil,
        scheduleStatus: String,
        isInClass: Bool = false,
        nextClassName: String? = nil,
        nextClassTeacher: String? = nil,
        nextClassRoom: String? = nil,
        nextClassStartTime: Date? = nil
    ) {
        self.currentClassName = currentClassName
        self.currentClassTeacher = currentClassTeacher
        self.currentClassRoom = currentClassRoom
        self.classStartTime = classStartTime
        self.classEndTime = classEndTime
        self.timeRemaining = timeRemaining
        self.progress = progress
        self.scheduleStatus = scheduleStatus
        self.isInClass = isInClass
        self.lastUpdated = Date()
        self.nextClassName = nextClassName
        self.nextClassTeacher = nextClassTeacher
        self.nextClassRoom = nextClassRoom
        self.nextClassStartTime = nextClassStartTime
    }
}

// MARK: - Data Provider

class MyLiveActivitiesDataProvider {
    static let shared = MyLiveActivitiesDataProvider()
    
    private let userDefaults: UserDefaults
    private let appGroupIdentifier = "group.club.ehsprogramming.ehsbellschedule"
    
    private init() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            self.userDefaults = sharedDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }
    
    func getLiveActivitiesData() -> MyLiveActivitiesData {
        print("🔍 MyLiveActivities requesting data...")
        
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            print("✅ Shared UserDefaults available")
            
            // Force refresh the shared UserDefaults
            sharedDefaults.synchronize()
            
            if let data = sharedDefaults.data(forKey: "liveActivitiesData") {
                print("📦 Found Live Activities data in shared UserDefaults, size: \(data.count) bytes")
                if let liveActivitiesData = try? JSONDecoder().decode(MyLiveActivitiesData.self, from: data) {
                    print("✅ Successfully decoded Live Activities data:")
                    print("   Status: \(liveActivitiesData.scheduleStatus)")
                    print("   Current class: \(liveActivitiesData.currentClassName ?? "nil")")
                    print("   Teacher: \(liveActivitiesData.currentClassTeacher ?? "nil")")
                    print("   Room: \(liveActivitiesData.currentClassRoom ?? "nil")")
                    print("   Time remaining: \(liveActivitiesData.timeRemaining ?? 0)")
                    print("   Is in class: \(liveActivitiesData.isInClass)")
                    print("   Last updated: \(liveActivitiesData.lastUpdated)")
                    
                    // Check if data is stale (older than 30 seconds)
                    let timeSinceUpdate = Date().timeIntervalSince(liveActivitiesData.lastUpdated)
                    if timeSinceUpdate > 30 {
                        print("⚠️ Data is stale! Last updated \(Int(timeSinceUpdate)) seconds ago")
                    } else {
                        print("✅ Data is fresh! Updated \(Int(timeSinceUpdate)) seconds ago")
                    }
                    
                    return liveActivitiesData
                } else {
                    print("❌ Failed to decode Live Activities data from shared UserDefaults")
                }
            } else {
                print("❌ No Live Activities data found in shared UserDefaults")
            }
        } else {
            print("❌ Shared UserDefaults not available")
        }
        
        // Fall back to local UserDefaults
        print("🔄 Falling back to local UserDefaults...")
        if let data = userDefaults.data(forKey: "liveActivitiesData") {
            print("📦 Found Live Activities data in local UserDefaults, size: \(data.count) bytes")
            if let liveActivitiesData = try? JSONDecoder().decode(MyLiveActivitiesData.self, from: data) {
                print("✅ Successfully decoded Live Activities data from local UserDefaults")
                return liveActivitiesData
            } else {
                print("❌ Failed to decode Live Activities data from local UserDefaults")
            }
        } else {
            print("❌ No Live Activities data found in local UserDefaults either")
        }
        
        print("⚠️ Returning default 'No Data' Live Activities data")
        return MyLiveActivitiesData(scheduleStatus: "No Data")
    }
    
    func saveLiveActivitiesData(_ data: MyLiveActivitiesData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            
            // Save to both shared and local UserDefaults
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                sharedDefaults.set(encoded, forKey: "liveActivitiesData")
                sharedDefaults.synchronize()
                print("✅ Saved Live Activities data to shared UserDefaults")
            }
            
            userDefaults.set(encoded, forKey: "liveActivitiesData")
            print("✅ Saved Live Activities data to local UserDefaults")
            
        } catch {
            print("❌ Failed to save Live Activities data: \(error)")
        }
    }
    
    func createContentState(from data: MyLiveActivitiesData) -> MyLiveActivitiesAttributes.ContentState {
        return MyLiveActivitiesAttributes.ContentState(
            currentClassName: data.currentClassName,
            currentClassTeacher: data.currentClassTeacher,
            currentClassRoom: data.currentClassRoom,
            classStartTime: data.classStartTime,
            classEndTime: data.classEndTime,
            timeRemaining: data.timeRemaining,
            progress: data.progress,
            scheduleStatus: data.scheduleStatus,
            isInClass: data.isInClass,
            lastUpdated: data.lastUpdated,
            nextClassName: data.nextClassName,
            nextClassTeacher: data.nextClassTeacher,
            nextClassRoom: data.nextClassRoom,
            nextClassStartTime: data.nextClassStartTime
        )
    }
}

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
        let authInfo = ActivityAuthorizationInfo()
        print("📊 Live Activity Authorization Status:")
        print("   Activities enabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("❌ Live Activities are not enabled")
            print("💡 Please enable Live Activities in Settings → Face ID & Passcode")
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
