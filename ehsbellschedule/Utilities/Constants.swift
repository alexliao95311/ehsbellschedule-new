import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Group
    static let appGroupIdentifier = "group.club.ehsprogramming.ehsbellschedule"
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let use24HourFormat = "use24HourFormat"
        static let showPeriod0 = "showPeriod0"
        static let showPeriod7 = "showPeriod7"
        static let customClassNames = "customClassNames"
        static let notificationMinutesBefore = "notificationMinutesBefore"
        static let enablePassingPeriodNotifications = "enablePassingPeriodNotifications"
        static let backgroundImageName = "backgroundImageName"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    // MARK: - Notification Categories
    struct NotificationCategories {
        static let classEnding = "CLASS_ENDING"
        static let passingPeriod = "PASSING_PERIOD"
    }
    
    // MARK: - Colors
    struct Colors {
        // Light Mode Colors
        static let lightPrimaryGreen = Color(red: 0.0, green: 0.2, blue: 0.1)        // Very dark forest green
        static let lightSecondaryGreen = Color(red: 0.0, green: 0.3, blue: 0.15)      // Dark forest green  
        static let lightAccentGreen = Color(red: 0.1, green: 0.4, blue: 0.2)         // Medium dark green
        static let lightBackgroundGray = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let lightCardBackground = Color(red: 1.0, green: 1.0, blue: 1.0)
        static let lightTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let lightTextSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)
        
        // Dark Mode Colors
        static let darkPrimaryGreen = Color(red: 0.2, green: 0.8, blue: 0.4)         // Bright green for dark mode
        static let darkSecondaryGreen = Color(red: 0.15, green: 0.6, blue: 0.3)      // Medium green for dark mode
        static let darkAccentGreen = Color(red: 0.1, green: 0.5, blue: 0.25)         // Darker accent green
        static let darkBackgroundGray = Color(red: 0.08, green: 0.08, blue: 0.08)    // Very dark background
        static let darkCardBackground = Color(red: 0.12, green: 0.12, blue: 0.12)    // Slightly lighter dark
        static let darkTextPrimary = Color(red: 0.95, green: 0.95, blue: 0.95)       // Light text
        static let darkTextSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)        // Medium light text
        
        // Dynamic Colors (these will change based on dark mode)
        static func primaryGreen(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkPrimaryGreen : lightPrimaryGreen
        }
        
        static func secondaryGreen(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkSecondaryGreen : lightSecondaryGreen
        }
        
        static func accentGreen(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkAccentGreen : lightAccentGreen
        }
        
        static func backgroundGray(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkBackgroundGray : lightBackgroundGray
        }
        
        static func cardBackground(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkCardBackground : lightCardBackground
        }
        
        static func textPrimary(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkTextPrimary : lightTextPrimary
        }
        
        static func textSecondary(_ isDarkMode: Bool) -> Color {
            return isDarkMode ? darkTextSecondary : lightTextSecondary
        }
        
        // Static colors that don't change
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)             // Bright success green
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)             // Bright warning yellow
        static let error = Color(red: 1.0, green: 0.4, blue: 0.4)               // Bright error red
        
        // Legacy aliases for backward compatibility (default to light mode)
        static let primaryGreen = lightPrimaryGreen
        static let secondaryGreen = lightSecondaryGreen
        static let backgroundGray = lightBackgroundGray
        static let cardBackground = lightCardBackground
        static let textPrimary = lightTextPrimary
        static let textSecondary = lightTextSecondary
        static let primaryBlue = lightPrimaryGreen
        static let secondaryBlue = lightSecondaryGreen
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