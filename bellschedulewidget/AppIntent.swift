//
//  AppIntent.swift
//  bellschedulewidget
//
//  Created by Alex Liao on 8/10/25.
//

import WidgetKit
import AppIntents

struct BellScheduleIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "EHS Schedule Configuration" }
    static var description: IntentDescription { "Configure your EHS schedule widget display options." }

    @Parameter(title: "Show 24-Hour Format", default: false)
    var use24HourFormat: Bool
    
    @Parameter(title: "Widget Style", default: .standard)
    var widgetStyle: WidgetStyle
}

enum WidgetStyle: String, AppEnum, CaseIterable {
    case standard = "Standard"
    case compact = "Compact" 
    case detailed = "Detailed"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Widget Style"
    }
    
    static var caseDisplayRepresentations: [WidgetStyle: DisplayRepresentation] {
        [
            .standard: "Standard",
            .compact: "Compact",
            .detailed: "Detailed"
        ]
    }
}
