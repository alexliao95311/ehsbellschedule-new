//
//  bellschedulewidget.swift
//  bellschedulewidget
//
//  Created by Alex Liao on 8/10/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct BellScheduleProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BellScheduleEntry {
        BellScheduleEntry(
            date: Date(),
            configuration: BellScheduleIntent(),
            widgetData: WidgetData(scheduleStatus: "Loading...")
        )
    }

    func snapshot(for configuration: BellScheduleIntent, in context: Context) async -> BellScheduleEntry {
        let widgetData = WidgetDataProvider.shared.getWidgetData()
        return BellScheduleEntry(
            date: Date(),
            configuration: configuration,
            widgetData: widgetData
        )
    }
    
    func timeline(for configuration: BellScheduleIntent, in context: Context) async -> Timeline<BellScheduleEntry> {
        let widgetData = WidgetDataProvider.shared.getWidgetData()
        let currentDate = Date()
        
        // Update every minute during school hours, every 15 minutes otherwise
        let isActiveTime = isSchoolActiveTime(currentDate)
        let updateInterval: TimeInterval = isActiveTime ? 60 : 15 * 60
        
        let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: currentDate) ?? currentDate
        
        let entry = BellScheduleEntry(
            date: currentDate,
            configuration: configuration,
            widgetData: widgetData
        )
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func isSchoolActiveTime(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        // Monday through Friday, 7 AM to 4 PM
        return weekday >= 2 && weekday <= 6 && hour >= 7 && hour <= 16
    }
}

// MARK: - Timeline Entry

struct BellScheduleEntry: TimelineEntry {
    let date: Date
    let configuration: BellScheduleIntent
    let widgetData: WidgetData
}

// MARK: - Widget Views

struct BellScheduleWidgetView: View {
    var entry: BellScheduleProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: BellScheduleProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Status
            Text(entry.widgetData.scheduleStatus)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Main content
            if let currentPeriod = entry.widgetData.currentPeriodName,
               let timeRemaining = entry.widgetData.timeRemaining {
                // Currently in class
                VStack(spacing: 4) {
                    Text(currentPeriod)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.currentPeriodTeacher,
                       let room = entry.widgetData.currentPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    
                    Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundColor(.green)
                }
                
            } else if let nextPeriod = entry.widgetData.nextPeriodName,
                      let startTime = entry.widgetData.nextPeriodStartTime {
                // Next class
                VStack(spacing: 4) {
                    Text("Next:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(nextPeriod)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.nextPeriodTeacher,
                       let room = entry.widgetData.nextPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    
                    Text(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                
            } else {
                // No active schedule
                VStack(spacing: 4) {
                    Image(systemName: scheduleStatusIcon)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(scheduleStatusMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private var scheduleStatusIcon: String {
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "calendar.badge.exclamationmark"
        case "After School":
            return "sunset"
        case "Before School":
            return "sunrise"
        default:
            return "clock"
        }
    }
    
    private var scheduleStatusMessage: String {
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "No School Today"
        case "After School":
            return "School's Out!"
        case "Before School":
            return "School Starts Soon"
        default:
            return entry.widgetData.scheduleStatus
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: BellScheduleProvider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Current/Next class info
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.widgetData.scheduleStatus)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if let currentPeriod = entry.widgetData.currentPeriodName,
                   let _ = entry.widgetData.timeRemaining,
                   let endTime = entry.widgetData.currentPeriodEndTime {
                    // Currently in class
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentPeriod)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Show teacher and room if available
                        if let teacher = entry.widgetData.currentPeriodTeacher,
                           let room = entry.widgetData.currentPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Ends:")
                            Text(WidgetTimeFormatter.shared.formatTime(endTime, use24Hour: entry.configuration.use24HourFormat))
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                } else if let nextPeriod = entry.widgetData.nextPeriodName,
                          let startTime = entry.widgetData.nextPeriodStartTime {
                    // Next class
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Up Next:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(nextPeriod)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Show teacher and room if available
                        if let teacher = entry.widgetData.nextPeriodTeacher,
                           let room = entry.widgetData.nextPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                }
                
                Spacer()
            }
            
            // Right side - Timer/Progress
            VStack {
                if let timeRemaining = entry.widgetData.timeRemaining {
                    // Countdown timer
                    VStack(spacing: 4) {
                        Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(.green)
                        
                        Text("remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress indicator
                    if let progress = entry.widgetData.progress {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(y: 2)
                    }
                    
                } else {
                    Image(systemName: scheduleStatusIcon)
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var scheduleStatusIcon: String {
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "calendar.badge.exclamationmark"
        case "After School":
            return "sunset"
        case "Before School":
            return "sunrise"
        default:
            return "clock"
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: BellScheduleProvider.Entry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EHS Schedule")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(entry.widgetData.scheduleStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
            
            // Main content area
            if let currentPeriod = entry.widgetData.currentPeriodName,
               let timeRemaining = entry.widgetData.timeRemaining,
               let progress = entry.widgetData.progress {
                // Currently in class view
                VStack(spacing: 12) {
                    Text(currentPeriod)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.currentPeriodTeacher,
                       let room = entry.widgetData.currentPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color.green.opacity(0.2), lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                                .font(.headline)
                                .fontWeight(.bold)
                                .monospacedDigit()
                            
                            Text("left")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
            } else {
                // No active class view
                VStack(spacing: 12) {
                    Image(systemName: scheduleStatusIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text(scheduleStatusMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    if let nextPeriod = entry.widgetData.nextPeriodName,
                       let startTime = entry.widgetData.nextPeriodStartTime {
                        VStack(spacing: 4) {
                            Text("Next: \(nextPeriod)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // Show teacher and room if available
                            if let teacher = entry.widgetData.nextPeriodTeacher,
                               let room = entry.widgetData.nextPeriodRoom {
                                Text("\(teacher) • Room \(room)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("at \(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var scheduleStatusIcon: String {
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "calendar.badge.exclamationmark"
        case "After School":
            return "sunset"
        case "Before School":
            return "sunrise"
        default:
            return "clock"
        }
    }
    
    private var scheduleStatusMessage: String {
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "No School Today"
        case "After School":
            return "School's Out!"
        case "Before School":
            return "School Starts Soon"
        default:
            return entry.widgetData.scheduleStatus
        }
    }
}

// MARK: - Widget Configuration

struct BellScheduleWidget: Widget {
    let kind: String = "bellschedulewidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: BellScheduleIntent.self, provider: BellScheduleProvider()) { entry in
            BellScheduleWidgetView(entry: entry)
                .containerBackground(Color("WidgetBackground").gradient, for: .widget)
        }
        .configurationDisplayName("EHS Schedule")
        .description("Stay updated with your current class schedule and countdown timers.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Previews

#Preview(as: .systemSmall) {
    BellScheduleWidget()
} timeline: {
    BellScheduleEntry(
        date: .now,
        configuration: BellScheduleIntent(),
        widgetData: WidgetData(
            currentPeriodName: "Mathematics",
            currentPeriodEndTime: Date().addingTimeInterval(15 * 60),
            scheduleStatus: "In Class",
            timeRemaining: 15 * 60,
            progress: 0.7
        )
    )
}

#Preview(as: .systemMedium) {
    BellScheduleWidget()
} timeline: {
    BellScheduleEntry(
        date: .now,
        configuration: BellScheduleIntent(),
        widgetData: WidgetData(
            nextPeriodName: "English Literature",
            nextPeriodStartTime: Date().addingTimeInterval(10 * 60),
            scheduleStatus: "Passing Period",
            timeRemaining: 10 * 60
        )
    )
}

#Preview(as: .systemLarge) {
    BellScheduleWidget()
} timeline: {
    BellScheduleEntry(
        date: .now,
        configuration: BellScheduleIntent(),
        widgetData: WidgetData(scheduleStatus: "After School")
    )
}
