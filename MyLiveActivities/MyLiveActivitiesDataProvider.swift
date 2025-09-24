//
//  MyLiveActivitiesDataProvider.swift
//  MyLiveActivities
//
//  Created by Alex Liao on 9/22/25.
//

import Foundation

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
}

// MARK: - Helper Extensions

extension MyLiveActivitiesDataProvider {
    
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
