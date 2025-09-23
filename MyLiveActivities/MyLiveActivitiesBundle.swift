//
//  MyLiveActivitiesBundle.swift
//  MyLiveActivities
//
//  Created by Alex Liao on 9/22/25.
//

import WidgetKit
import SwiftUI

@main
struct MyLiveActivitiesBundle: WidgetBundle {
    var body: some Widget {
        MyLiveActivities()
        MyLiveActivitiesControl()
        MyLiveActivitiesLiveActivity()
    }
}
