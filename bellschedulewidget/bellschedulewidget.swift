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
        
        // Update every second for real-time countdown
        let updateInterval: TimeInterval = 1
        
        // Get base widget data once
        let baseWidgetData = WidgetDataProvider.shared.getWidgetData()
        
        // Create entries for the next 120 updates (2 minutes worth at 1-second intervals)
        for i in 0..<120 {
            let entryDate = Calendar.current.date(byAdding: .second, value: Int(updateInterval * Double(i)), to: currentDate) ?? currentDate
            
            // Recalculate time remaining and progress for this specific entry time
            var updatedWidgetData = baseWidgetData
            
            if let endTime = baseWidgetData.currentPeriodEndTime {
                let timeRemaining = endTime.timeIntervalSince(entryDate)
                if timeRemaining > 0 {
                    // Update time remaining for this entry
                    updatedWidgetData = WidgetData(
                        currentPeriodName: baseWidgetData.currentPeriodName,
                        currentPeriodEndTime: baseWidgetData.currentPeriodEndTime,
                        currentPeriodTeacher: baseWidgetData.currentPeriodTeacher,
                        currentPeriodRoom: baseWidgetData.currentPeriodRoom,
                        nextPeriodName: baseWidgetData.nextPeriodName,
                        nextPeriodStartTime: baseWidgetData.nextPeriodStartTime,
                        nextPeriodTeacher: baseWidgetData.nextPeriodTeacher,
                        nextPeriodRoom: baseWidgetData.nextPeriodRoom,
                        scheduleStatus: baseWidgetData.scheduleStatus,
                        timeRemaining: timeRemaining,
                        progress: calculateProgress(for: entryDate, endTime: endTime, baseData: baseWidgetData)
                    )
                } else {
                    // Period has ended, clear current period data
                    updatedWidgetData = WidgetData(
                        currentPeriodName: nil,
                        currentPeriodEndTime: nil,
                        currentPeriodTeacher: nil,
                        currentPeriodRoom: nil,
                        nextPeriodName: baseWidgetData.nextPeriodName,
                        nextPeriodStartTime: baseWidgetData.nextPeriodStartTime,
                        nextPeriodTeacher: baseWidgetData.nextPeriodTeacher,
                        nextPeriodRoom: baseWidgetData.nextPeriodRoom,
                        scheduleStatus: "Between Classes",
                        timeRemaining: nil,
                        progress: nil
                    )
                }
            }
            
            print("📅 Timeline entry \(i): Entry time: \(entryDate), time remaining: \(updatedWidgetData.timeRemaining ?? 0)")
            
            let entry = BellScheduleEntry(
                date: entryDate,
                configuration: configuration,
                widgetData: updatedWidgetData
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: currentDate) ?? currentDate))
    }
    
    private func calculateProgress(for entryDate: Date, endTime: Date, baseData: WidgetData) -> Double? {
        // Match the main app's progress calculation: elapsed / duration
        if let originalTimeRemaining = baseData.timeRemaining {
            // Calculate the start time: endTime - originalTimeRemaining (when data was last updated)
            let startTime = endTime.addingTimeInterval(-originalTimeRemaining)
            
            // Calculate duration and elapsed time using the same method as Period model
            let duration = endTime.timeIntervalSince(startTime)
            let elapsed = entryDate.timeIntervalSince(startTime)
            
            if duration > 0 {
                // Use the exact same formula as Period.progress(from:)
                let progress = elapsed / duration
                return min(1.0, max(0.0, progress))
            }
        }
        return baseData.progress
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
        VStack(spacing: 0) {
            // Top margin
            Spacer()
                .frame(height: 8)
            
            // Status badge - centered
            Text(entry.widgetData.scheduleStatus)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.8))
                .cornerRadius(4)
            
            Spacer()
            
            // Main content - centered
            if let currentPeriod = entry.widgetData.currentPeriodName,
               let timeRemaining = entry.widgetData.timeRemaining {
                // Currently in class
                VStack(spacing: 6) {
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
                        .contentTransition(.numericText())
                    
                    Text("remaining")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
            } else if let nextPeriod = entry.widgetData.nextPeriodName,
                      let startTime = entry.widgetData.nextPeriodStartTime {
                // Next class
                VStack(spacing: 6) {
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
                VStack(spacing: 6) {
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
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .clipShape(ContainerRelativeShape())
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
        HStack(spacing: 12) {
            // Left side - Class info
            VStack(alignment: .leading, spacing: 0) {
                // Status badge at top
                HStack {
                    Text(entry.widgetData.scheduleStatus)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(6)
                    
                    Spacer()
                }
                
                Spacer()
                
                if let currentPeriod = entry.widgetData.currentPeriodName,
                   let _ = entry.widgetData.timeRemaining,
                   let endTime = entry.widgetData.currentPeriodEndTime {
                    // Currently in class
                    VStack(alignment: .leading, spacing: 3) {
                        Text(currentPeriod)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        if let teacher = entry.widgetData.currentPeriodTeacher,
                           let room = entry.widgetData.currentPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Text("Ends \(WidgetTimeFormatter.shared.formatTime(endTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .monospacedDigit()
                        }
                    }
                    
                } else if let nextPeriod = entry.widgetData.nextPeriodName,
                          let startTime = entry.widgetData.nextPeriodStartTime {
                    // Next class
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Up Next")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text(nextPeriod)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        if let teacher = entry.widgetData.nextPeriodTeacher,
                           let room = entry.widgetData.nextPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Text("Starts \(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                    }
                    
                } else {
                    // No schedule
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: scheduleStatusIcon)
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        Text(scheduleStatusMessage)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Right side - Timer (50% of space)
            VStack {
                Spacer()
                
                if let timeRemaining = entry.widgetData.timeRemaining {
                    VStack(spacing: 4) {
                        Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                            .font(.system(size: 34, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: scheduleStatusIcon)
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text("No Timer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .clipShape(ContainerRelativeShape())
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

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: BellScheduleProvider.Entry
    
    var body: some View {
        VStack(spacing: 16) {
            // Top margin for better centering
            Spacer()
                .frame(height: 8)
            
            // Header - Status badge only
            HStack {
                Text(entry.widgetData.scheduleStatus)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(6)
                
                Spacer()
            }
            
            // Main content area - centered
            if let currentPeriod = entry.widgetData.currentPeriodName,
               let timeRemaining = entry.widgetData.timeRemaining,
               let endTime = entry.widgetData.currentPeriodEndTime {
                // Currently in class view
                VStack(spacing: 20) {
                    Text(currentPeriod)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Show teacher and room if available
                    if let teacher = entry.widgetData.currentPeriodTeacher,
                       let room = entry.widgetData.currentPeriodRoom {
                        Text("\(teacher) • Room \(room)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Time remaining - simplified without circle
                    VStack(spacing: 8) {
                        Text(WidgetTimeFormatter.shared.formatCountdown(timeRemaining))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        
                        Text("remaining")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Show when class ends
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Text("Ends: \(WidgetTimeFormatter.shared.formatTime(endTime, use24Hour: entry.configuration.use24HourFormat))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity)
                
            } else {
                // No active class view
                VStack(spacing: 16) {
                    Image(systemName: scheduleStatusIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text(scheduleStatusMessage)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Show next class section if available
            if let nextPeriod = entry.widgetData.nextPeriodName,
               let startTime = entry.widgetData.nextPeriodStartTime {
                VStack(spacing: 16) {
                    // Divider line
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        Text("Next Class")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text(nextPeriod)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        // Show teacher and room if available
                        if let teacher = entry.widgetData.nextPeriodTeacher,
                           let room = entry.widgetData.nextPeriodRoom {
                            Text("\(teacher) • Room \(room)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            
                            Text("Starts: \(WidgetTimeFormatter.shared.formatTime(startTime, use24Hour: entry.configuration.use24HourFormat))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .monospacedDigit()
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .clipShape(ContainerRelativeShape())
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
        }
        .configurationDisplayName("EHS Schedule")
        .description("Stay updated with your current class schedule and countdown timers.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
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
            currentPeriodName: "AP Physics C",
            currentPeriodEndTime: Date().addingTimeInterval(20 * 60 + 54),
            currentPeriodTeacher: "Casavant",
            currentPeriodRoom: "F304",
            nextPeriodName: "English Literature",
            nextPeriodStartTime: Date().addingTimeInterval(25 * 60),
            nextPeriodTeacher: "Johnson",
            nextPeriodRoom: "E201",
            scheduleStatus: "In Class",
            timeRemaining: 20 * 60 + 54,
            progress: 0.7
        )
    )
}

#Preview(as: .systemLarge) {
    BellScheduleWidget()
} timeline: {
    BellScheduleEntry(
        date: .now,
        configuration: BellScheduleIntent(),
        widgetData: WidgetData(
            currentPeriodName: "AP Physics C",
            currentPeriodEndTime: Date().addingTimeInterval(25 * 60),
            currentPeriodTeacher: "Casavant",
            currentPeriodRoom: "F304",
            nextPeriodName: "English Literature",
            nextPeriodStartTime: Date().addingTimeInterval(30 * 60),
            nextPeriodTeacher: "Johnson",
            nextPeriodRoom: "E201",
            scheduleStatus: "In Class",
            timeRemaining: 25 * 60,
            progress: 0.7
        )
    )
}
