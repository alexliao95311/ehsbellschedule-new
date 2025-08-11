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
        var timeRemaining: TimeInterval?
        var nextPeriodName: String?
        var nextPeriodStartTime: Date?
        var scheduleStatus: String
        var progress: Double?
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
        HStack(spacing: 12) {
            // Left side - Period info
            VStack(alignment: .leading, spacing: 4) {
                Text("EHS Schedule")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let currentPeriod = context.state.currentPeriodName {
                    Text(currentPeriod)
                        .font(.headline)
                        .fontWeight(.semibold)
                } else if let nextPeriod = context.state.nextPeriodName {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(nextPeriod)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                } else {
                    Text(context.state.scheduleStatus)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // Right side - Timer
            if let timeRemaining = context.state.timeRemaining {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundColor(.green)
                    
                    Text("remaining")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: statusIcon(for: context.state.scheduleStatus))
                    .font(.title2)
                    .foregroundColor(.green)
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
            Text("EHS")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let currentPeriod = context.state.currentPeriodName {
                Text(currentPeriod)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            } else {
                Text(context.state.scheduleStatus)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
        }
    }
    
    @ViewBuilder
    private func expandedTrailingView(context: ActivityViewContext<BellScheduleActivityAttributes>) -> some View {
        if let timeRemaining = context.state.timeRemaining {
            VStack(alignment: .trailing, spacing: 4) {
                Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(.green)
                
                Text("left")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        } else {
            Image(systemName: statusIcon(for: context.state.scheduleStatus))
                .font(.title)
                .foregroundColor(.green)
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
                Text("Next: \(nextPeriod)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("at \(WidgetTimeFormatter.shared.formatTime(nextStartTime, use24Hour: false))")
                    .font(.caption)
                    .monospacedDigit()
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
        if let timeRemaining = context.state.timeRemaining {
            Text(WidgetTimeFormatter.shared.formatTimeUntil(timeRemaining))
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()
        } else {
            Image(systemName: statusIcon(for: context.state.scheduleStatus))
                .font(.caption)
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
            timeRemaining: 15 * 60,
            scheduleStatus: "In Class",
            progress: 0.7
        )
    }
     
    fileprivate static var passingToEnglish: BellScheduleActivityAttributes.ContentState {
        BellScheduleActivityAttributes.ContentState(
            timeRemaining: 5 * 60,
            nextPeriodName: "English Literature",
            nextPeriodStartTime: Date().addingTimeInterval(5 * 60),
            scheduleStatus: "Passing Period"
        )
    }
    
    fileprivate static var noSchool: BellScheduleActivityAttributes.ContentState {
        BellScheduleActivityAttributes.ContentState(
            scheduleStatus: "No School"
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
