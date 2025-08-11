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
        // Always fetch fresh data for each timeline entry
        let currentDate = Date()
        
        // Create multiple entries for very frequent updates
        var entries: [BellScheduleEntry] = []
        
        // Update every 10 seconds during school hours, every 30 seconds otherwise
        let isActiveTime = isSchoolActiveTime(currentDate)
        let updateInterval: TimeInterval = isActiveTime ? 10 : 30
        
        // Create entries for the next 20 updates (more frequent)
        for i in 0..<20 {
            let entryDate = Calendar.current.date(byAdding: .second, value: Int(updateInterval * Double(i)), to: currentDate) ?? currentDate
            
            // Fetch fresh data for each entry to ensure accuracy
            let freshWidgetData = WidgetDataProvider.shared.getWidgetData()
            print("📅 Timeline entry \(i): Using data from \(freshWidgetData.lastUpdated), time remaining: \(freshWidgetData.timeRemaining ?? 0)")
            
            let entry = BellScheduleEntry(
                date: entryDate,
                configuration: configuration,
                widgetData: freshWidgetData
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: currentDate) ?? currentDate))
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
            // Status badge
            Text(entry.widgetData.scheduleStatus)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.8))
                .cornerRadius(4)
            
            // Main content
            if let currentPeriod = entry.widgetData.currentPeriodName,
               let timeRemaining = entry.widgetData.timeRemaining {
                // Currently in class
                VStack(spacing: 4) {
                    Text(currentPeriod)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.currentPeriodTeacher,
                       let room = entry.widgetData.currentPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    
                    Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .monospacedDigit()
                }
                
            } else if let nextPeriod = entry.widgetData.nextPeriodName,
                      let startTime = entry.widgetData.nextPeriodStartTime {
                // Next class
                VStack(spacing: 4) {
                    Text("Next:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(nextPeriod)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.nextPeriodTeacher,
                       let room = entry.widgetData.nextPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    
                    Text(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .monospacedDigit()
                }
                
            } else {
                // No active schedule
                VStack(spacing: 4) {
                    Image(systemName: scheduleStatusIcon)
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text(scheduleStatusMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Color.black
        )
        .cornerRadius(12)
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
        // Add debug info to see what's happening
        let debugInfo = "Status: \(entry.widgetData.scheduleStatus)"
        let dataInfo = "Data: \(entry.widgetData.currentPeriodName ?? "nil")"
        
        switch entry.widgetData.scheduleStatus {
        case "No School":
            return "No School Today\n\(debugInfo)\n\(dataInfo)"
        case "After School":
            return "School's Out!\n\(debugInfo)\n\(dataInfo)"
        case "Before School":
            return "School Starts Soon\n\(debugInfo)\n\(dataInfo)"
        default:
            return "\(entry.widgetData.scheduleStatus)\n\(debugInfo)\n\(dataInfo)"
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
                // Status badge
                Text(entry.widgetData.scheduleStatus)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(6)
                
                if let currentPeriod = entry.widgetData.currentPeriodName,
                   let _ = entry.widgetData.timeRemaining,
                   let endTime = entry.widgetData.currentPeriodEndTime {
                    // Currently in class
                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentPeriod)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Show teacher and room if available
                        if let teacher = entry.widgetData.currentPeriodTeacher,
                           let room = entry.widgetData.currentPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Ends: \(WidgetTimeFormatter.shared.formatTime(endTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .monospacedDigit()
                        }
                    }
                    
                } else if let nextPeriod = entry.widgetData.nextPeriodName,
                          let startTime = entry.widgetData.nextPeriodStartTime {
                    // Next class
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Up Next:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text(nextPeriod)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Show teacher and room if available
                        if let teacher = entry.widgetData.nextPeriodTeacher,
                           let room = entry.widgetData.nextPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Starts: \(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .monospacedDigit()
                        }
                    }
                }
                
                Spacer()
            }
            
            // Right side - Timer/Progress
            VStack(spacing: 8) {
                if let timeRemaining = entry.widgetData.timeRemaining {
                    // Countdown timer
                    VStack(spacing: 6) {
                        Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .monospacedDigit()
                        
                        Text("remaining")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Progress indicator
                    if let progress = entry.widgetData.progress {
                        VStack(spacing: 4) {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .scaleEffect(y: 3)
                                .frame(height: 12)
                            
                            Text("\(Int(progress * 100))% complete")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                } else {
                    // No active timer
                    VStack(spacing: 8) {
                        Image(systemName: scheduleStatusIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text(entry.widgetData.scheduleStatus)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black
        )
        .cornerRadius(16)
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
