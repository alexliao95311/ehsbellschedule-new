import Foundation
import UserNotifications

struct NotificationSettings: Codable {
    let isEnabled: Bool
    let minutesBefore: Int
    let includePassingPeriods: Bool
    
    static let `default` = NotificationSettings(
        isEnabled: false,
        minutesBefore: 2,
        includePassingPeriods: false
    )
}

enum NotificationType {
    case classEnding(period: Period, minutesRemaining: Int)
    case passingPeriod(nextPeriod: Period)
    
    var identifier: String {
        switch self {
        case .classEnding(let period, let minutes):
            return "class_ending_\(period.number)_\(minutes)min"
        case .passingPeriod(let period):
            return "passing_period_\(period.number)"
        }
    }
    
    var title: String {
        switch self {
        case .classEnding(let period, _):
            return "\(period.defaultName) ending soon"
        case .passingPeriod(_):
            return "Passing Period"
        }
    }
    
    var body: String {
        switch self {
        case .classEnding(let period, let minutes):
            return "\(period.defaultName) ends in \(minutes) minute\(minutes == 1 ? "" : "s")"
        case .passingPeriod(let period):
            return "\(period.defaultName) starts soon"
        }
    }
}