//
//  bellschedulewidgetControl.swift
//  bellschedulewidget
//
//  Created by Alex Liao on 8/10/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct BellScheduleControl: ControlWidget {
    static let kind: String = "club.ehsprogramming.ehsbellschedule.bellschedule.control"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: OpenScheduleAppIntent()) {
                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .font(.caption)
                    
                    if let currentPeriod = value.currentPeriodName {
                        Text(currentPeriod)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    } else {
                        Text(value.scheduleStatus)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    if let timeRemaining = value.timeRemaining {
                        Text(WidgetTimeFormatter.shared.formatTimeUntil(timeRemaining))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                }
            }
        }
        .displayName("Bell Schedule")
        .description("Quick access to your current class schedule and timing information.")
    }
}

extension BellScheduleControl {
    struct Value {
        var currentPeriodName: String?
        var timeRemaining: TimeInterval?
        var scheduleStatus: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: BellScheduleControlConfiguration) -> Value {
            BellScheduleControl.Value(
                currentPeriodName: "Mathematics",
                timeRemaining: 15 * 60,
                scheduleStatus: "In Class"
            )
        }

        func currentValue(configuration: BellScheduleControlConfiguration) async throws -> Value {
            let widgetData = WidgetDataProvider.shared.getWidgetData()
            
            return BellScheduleControl.Value(
                currentPeriodName: widgetData.currentPeriodName,
                timeRemaining: widgetData.timeRemaining,
                scheduleStatus: widgetData.scheduleStatus
            )
        }
    }
}

struct BellScheduleControlConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Bell Schedule Control Configuration"

    @Parameter(title: "Show Time Remaining", default: true)
    var showTimeRemaining: Bool
}

struct OpenScheduleAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Bell Schedule App"
    static let description = IntentDescription("Opens the Bell Schedule app to view detailed schedule information.")

    func perform() async throws -> some IntentResult {
        // This intent will open the main app when the control is tapped
        return .result()
    }
}
