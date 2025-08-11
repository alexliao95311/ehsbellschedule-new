//
//  bellschedulewidgetBundle.swift
//  bellschedulewidget
//
//  Created by Alex Liao on 8/10/25.
//

import WidgetKit
import SwiftUI

@main
struct BellScheduleWidgetBundle: WidgetBundle {
    var body: some Widget {
        BellScheduleWidget()
        BellScheduleControl()
        BellScheduleLiveActivity()
    }
}
