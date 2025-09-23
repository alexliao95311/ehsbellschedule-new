//
//  bellschedulewidgetLiveActivity.swift
//  bellschedulewidget
//
//  Created by Alex Liao on 8/10/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

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

// MARK: - Live Activity Widget

struct BellScheduleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BellScheduleActivityAttributes.self) { context in
            // Lock screen/banner UI
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
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
    private func lockScreenView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("EHS Bell Schedule")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if context.state.isInClass {
                    Text("In Class")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(4)
                }
            }
            
            // Main content
            HStack(spacing: 16) {
                // Left side - Period info
                VStack(alignment: .leading, spacing: 4) {
                    if let currentPeriod = context.state.currentPeriodName {
                        Text(currentPeriod)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        if let teacher = context.state.currentPeriodTeacher,
                           let room = context.state.currentPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        if let endTime = context.state.currentPeriodEndTime {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                
                                Text("Ends at \(WidgetTimeFormatter.shared.formatTime(endTime, use24Hour: false))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    } else if let nextPeriod = context.state.nextPeriodName {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Class")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(nextPeriod)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(2)
                            
                            if let teacher = context.state.nextPeriodTeacher,
                               let room = context.state.nextPeriodRoom {
                                Text("\(teacher) • Room \(room)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            if let startTime = context.state.nextPeriodStartTime {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    
                                    Text("Starts at \(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: false))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .monospacedDigit()
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.scheduleStatus)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: statusIcon(for: context.state.scheduleStatus))
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Right side - Timer
                if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(context.state.isInClass ? .green : .blue)
                            .contentTransition(.numericText())
                        
                        Text(context.state.isInClass ? "remaining" : "until next")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if let progress = context.state.progress {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: context.state.isInClass ? .green : .blue))
                                .frame(width: 60)
                        }
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: statusIcon(for: context.state.scheduleStatus))
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text(context.state.scheduleStatus)
                            .font(.caption2)
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
    private func expandedLeadingView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "bell")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("EHS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            if let currentPeriod = context.state.currentPeriodName {
                Text(currentPeriod)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let teacher = context.state.currentPeriodTeacher,
                   let room = context.state.currentPeriodRoom {
                    Text("\(teacher) • \(room)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            } else if let nextPeriod = context.state.nextPeriodName {
                Text("Next: \(nextPeriod)")
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
    private func expandedTrailingView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
            VStack(alignment: .trailing, spacing: 4) {
                Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
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
                Image(systemName: statusIcon(for: context.state.scheduleStatus))
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
    private func expandedCenterView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        if let progress = context.state.progress {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(y: 2)
        }
    }
    
    @ViewBuilder
    private func expandedBottomView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        if let nextPeriod = context.state.nextPeriodName,
           let nextStartTime = context.state.nextPeriodStartTime {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next: \(nextPeriod)")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if let teacher = context.state.nextPeriodTeacher,
                       let room = context.state.nextPeriodRoom {
                        Text("\(teacher) • \(room)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("at \(WidgetTimeFormatter.shared.formatTime(nextStartTime, use24Hour: false))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .monospacedDigit()
                    
                    if let timeRemaining = context.state.timeRemaining, !context.state.isInClass {
                        Text("in \(WidgetTimeFormatter.shared.formatTimeUntil(timeRemaining))")
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
    private func compactLeadingView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        Image(systemName: "bell")
            .font(.caption)
            .foregroundColor(.blue)
    }
    
    @ViewBuilder
    private func compactTrailingView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        if let timeRemaining = context.state.timeRemaining, timeRemaining > 0 {
            VStack(spacing: 2) {
                Text(WidgetTimeFormatter.shared.formatTimeUntil(timeRemaining))
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
            Image(systemName: statusIcon(for: context.state.scheduleStatus))
                .font(.caption)
                .foregroundColor(.green)
        }
    }
    
    @ViewBuilder
    private func minimalView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        Image(systemName: "bell.fill")
            .font(.caption)
            .foregroundColor(.blue)
    }
    
    // MARK: - Helper Functions
    
    private func statusIcon(for status: String) -> String {
        switch status {
        case "No School":
            return "calendar.badge.exclamationmark"
        case "After School":
            return "sunset.fill"
        case "Before School":
            return "sunrise.fill"
        case "Passing Period":
            return "figure.walk"
        default:
            return "clock"
        }
    }
}

// MARK: - Preview Extensions

extension BellScheduleActivityAttributes {
    fileprivate static var inClass: BellScheduleActivityAttributes {
        BellScheduleActivityAttributes(schoolName: "EHS")
    }
    
    fileprivate static var passingPeriod: BellScheduleActivityAttributes {
        BellScheduleActivityAttributes(schoolName: "EHS")
    }
}

extension BellScheduleActivityAttributes.ContentState {
    fileprivate static var inMath: BellScheduleActivityAttributes.ContentState {
        BellScheduleActivityAttributes.ContentState(
            currentPeriodName: "Mathematics",
            currentPeriodTeacher: "Casavant",
            currentPeriodRoom: "F304",
            currentPeriodEndTime: Date().addingTimeInterval(15 * 60),
            timeRemaining: 15 * 60,
            nextPeriodName: "English Literature",
            nextPeriodTeacher: "Johnson",
            nextPeriodRoom: "E201",
            nextPeriodStartTime: Date().addingTimeInterval(20 * 60),
            scheduleStatus: "In Class",
            progress: 0.7,
            isInClass: true,
            lastUpdated: Date()
        )
    }
     
    fileprivate static var passingToEnglish: BellScheduleActivityAttributes.ContentState {
        BellScheduleActivityAttributes.ContentState(
            timeRemaining: 5 * 60,
            nextPeriodName: "English Literature",
            nextPeriodTeacher: "Johnson",
            nextPeriodRoom: "E201",
            nextPeriodStartTime: Date().addingTimeInterval(5 * 60),
            scheduleStatus: "Passing Period",
            isInClass: false,
            lastUpdated: Date()
        )
    }
    
    fileprivate static var noSchool: BellScheduleActivityAttributes.ContentState {
        BellScheduleActivityAttributes.ContentState(
            scheduleStatus: "No School",
            isInClass: false,
            lastUpdated: Date()
        )
    }
}

// MARK: - Previews

#Preview("In Class", as: .content, using: BellScheduleActivityAttributes.inClass) {
   BellScheduleLiveActivity()
} contentStates: {
    BellScheduleActivityAttributes.ContentState.inMath
}

#Preview("Passing Period", as: .content, using: BellScheduleActivityAttributes.passingPeriod) {
   BellScheduleLiveActivity()
} contentStates: {
    BellScheduleActivityAttributes.ContentState.passingToEnglish
}

#Preview("No School", as: .content, using: BellScheduleActivityAttributes.passingPeriod) {
   BellScheduleLiveActivity()
} contentStates: {
    BellScheduleActivityAttributes.ContentState.noSchool
}
