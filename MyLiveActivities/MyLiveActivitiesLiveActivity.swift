//
//  MyLiveActivitiesLiveActivity.swift
//  MyLiveActivities
//
//  Created by Alex Liao on 9/22/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

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

struct MyLiveActivitiesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivitiesAttributes.self) { context in
            // Lock screen/banner UI goes here
            lockScreenView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    expandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    expandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    expandedCenterView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedBottomView(context: context)
                }
            } compactLeading: {
                compactLeadingView(context: context)
            } compactTrailing: {
                compactTrailingView(context: context)
            } minimal: {
                minimalView(context: context)
            }
            .keylineTint(Color.green)
        }
    }
    
    // MARK: - Lock Screen View
    
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("EHS Bell Schedule")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if context.state.isInClass {
                    Text("In Class")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .cornerRadius(6)
                }
            }
            
            // Main content
            HStack(spacing: 16) {
                // Left side - Class info
                VStack(alignment: .leading, spacing: 6) {
                    if let className = context.state.currentClassName {
                        Text(className)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        if let teacher = context.state.currentClassTeacher,
                           let room = context.state.currentClassRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        if let startTime = context.state.classStartTime,
                           let endTime = context.state.classEndTime {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Start")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(formatTime(startTime))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .monospacedDigit()
                                }
                                
                                Text("→")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("End")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(formatTime(endTime))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .monospacedDigit()
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(context.state.scheduleStatus)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if let nextClass = context.state.nextClassName {
                                Text("Next: \(nextClass)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Right side - Countdown timer
                if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
                    VStack(spacing: 6) {
                        Text(formatCountdown(timeRemaining))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(context.state.isInClass ? .green : .blue)
                            .contentTransition(.numericText())
                        
                        Text(context.state.isInClass ? "remaining" : "until next")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let progress = context.state.progress {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: context.state.isInClass ? .green : .blue))
                                .frame(width: 80)
                        }
                    }
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text(context.state.scheduleStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .activityBackgroundTint(Color.black.opacity(0.1))
        .activitySystemActionForegroundColor(Color.blue)
    }
    
    // MARK: - Dynamic Island Views
    
    @ViewBuilder
    private func expandedLeadingView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "bell")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("EHS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            if let className = context.state.currentClassName {
                Text(className)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let teacher = context.state.currentClassTeacher,
                   let room = context.state.currentClassRoom {
                    Text("\(teacher) • \(room)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            } else if let nextClass = context.state.nextClassName {
                Text("Next: \(nextClass)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            } else {
                Text(context.state.scheduleStatus)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder
    private func expandedTrailingView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCountdown(timeRemaining))
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(context.state.isInClass ? .green : .blue)
                    .contentTransition(.numericText())
                
                Text(context.state.isInClass ? "left" : "next")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if context.state.isInClass {
                    Image(systemName: "person.3.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        } else {
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text(context.state.scheduleStatus)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder
    private func expandedCenterView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        if let progress = context.state.progress {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: context.state.isInClass ? .green : .blue))
                .scaleEffect(y: 2)
        }
    }
    
    @ViewBuilder
    private func expandedBottomView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        if let nextClass = context.state.nextClassName,
           let nextStartTime = context.state.nextClassStartTime {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next: \(nextClass)")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if let teacher = context.state.nextClassTeacher,
                       let room = context.state.nextClassRoom {
                        Text("\(teacher) • \(room)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("at \(formatTime(nextStartTime))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .monospacedDigit()
                    
                    if let timeRemaining = context.state.timeRemaining, !context.state.isInClass {
                        Text("in \(formatTimeUntil(timeRemaining))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } else {
            HStack {
                Text("No upcoming classes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func compactLeadingView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        Image(systemName: "bell")
            .font(.caption)
            .foregroundColor(.green)
    }
    
    @ViewBuilder
    private func compactTrailingView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
            VStack(spacing: 2) {
                Text(formatTimeUntil(timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundColor(context.state.isInClass ? .green : .blue)
                
                if context.state.isInClass {
                    Image(systemName: "person.3.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        } else {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(.green)
        }
    }
    
    @ViewBuilder
    private func minimalView(context: ActivityViewContext<MyLiveActivitiesAttributes>) -> some View {
        Image(systemName: "bell.fill")
            .font(.caption)
            .foregroundColor(.green)
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatCountdown(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, timeInterval))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func formatTimeUntil(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
}

extension MyLiveActivitiesAttributes {
    fileprivate static var preview: MyLiveActivitiesAttributes {
        MyLiveActivitiesAttributes(schoolName: "EHS")
    }
}

extension MyLiveActivitiesAttributes.ContentState {
    fileprivate static var inClass: MyLiveActivitiesAttributes.ContentState {
        MyLiveActivitiesAttributes.ContentState(
            currentClassName: "AP Physics C",
            currentClassTeacher: "Casavant",
            currentClassRoom: "F304",
            classStartTime: Date().addingTimeInterval(-15 * 60),
            classEndTime: Date().addingTimeInterval(25 * 60),
            timeRemaining: 25 * 60,
            progress: 0.6,
            scheduleStatus: "In Class",
            isInClass: true,
            lastUpdated: Date(),
            nextClassName: "English Literature",
            nextClassTeacher: "Johnson",
            nextClassRoom: "E201",
            nextClassStartTime: Date().addingTimeInterval(30 * 60)
        )
    }
     
    fileprivate static var passingPeriod: MyLiveActivitiesAttributes.ContentState {
        MyLiveActivitiesAttributes.ContentState(
            timeRemaining: 5 * 60,
            scheduleStatus: "Passing Period",
            isInClass: false,
            lastUpdated: Date(),
            nextClassName: "English Literature",
            nextClassTeacher: "Johnson",
            nextClassRoom: "E201",
            nextClassStartTime: Date().addingTimeInterval(5 * 60)
        )
    }
}

#Preview("In Class", as: .content, using: MyLiveActivitiesAttributes.preview) {
   MyLiveActivitiesLiveActivity()
} contentStates: {
    MyLiveActivitiesAttributes.ContentState.inClass
    MyLiveActivitiesAttributes.ContentState.passingPeriod
}
