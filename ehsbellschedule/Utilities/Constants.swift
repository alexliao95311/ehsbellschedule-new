import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Group
    static let appGroupIdentifier = "group.club.ehsprogramming.ehsbellschedule"
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let showPeriod0 = "showPeriod0"
        static let showPeriod7 = "showPeriod7"
        static let customClassNames = "customClassNames"
        static let customClassInfo = "customClassInfo"
        static let notificationMinutesBefore = "notificationMinutesBefore"
        static let enablePassingPeriodNotifications = "enablePassingPeriodNotifications"
        static let backgroundImageName = "backgroundImageName"
        static let widgetData = "widgetData"
    }
    
    // MARK: - Notification Categories
    struct NotificationCategories {
        static let classEnding = "CLASS_ENDING"
        static let passingPeriod = "PASSING_PERIOD"
    }
    
    // MARK: - Colors
    struct Colors {
        // Dark Green Theme Colors
        static let primaryGreen = Color(red: 0.0, green: 0.2, blue: 0.1)        // Very dark forest green
        static let secondaryGreen = Color(red: 0.0, green: 0.3, blue: 0.15)      // Dark forest green  
        static let accentGreen = Color(red: 0.1, green: 0.4, blue: 0.2)         // Medium dark green
        static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let cardBackground = Color(red: 1.0, green: 1.0, blue: 1.0)
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)             // Bright success green
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)             // Bright warning yellow
        static let error = Color(red: 1.0, green: 0.4, blue: 0.4)               // Bright error red
        
        // Legacy aliases for backward compatibility
        static let primaryBlue = primaryGreen
        static let secondaryBlue = secondaryGreen
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title = Font.system(size: 28, weight: .semibold, design: .default)
        static let headline = Font.system(size: 22, weight: .medium, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let countdown = Font.system(size: 48, weight: .bold, design: .monospaced)
    }
    
    // MARK: - Animation
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.interpolatingSpring(stiffness: 300, damping: 30)
    }
    
    // MARK: - Layout
    struct Layout {
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 44
        static let minimumTouchTarget: CGFloat = 44
    }
    
    // MARK: - Timing
    struct Timing {
        static let countdownUpdateInterval: TimeInterval = 0.5  // Update every 0.5 seconds instead of 1 second
        static let notificationRequestInterval: TimeInterval = 60.0
        static let defaultNotificationMinutes = 2
        static let passingPeriodMinutes = 9
    }
    
    // MARK: - Widget
    struct Widget {
        static let smallSize = CGSize(width: 158, height: 158)
        static let mediumSize = CGSize(width: 338, height: 158)
        static let largeSize = CGSize(width: 338, height: 354)
    }
}