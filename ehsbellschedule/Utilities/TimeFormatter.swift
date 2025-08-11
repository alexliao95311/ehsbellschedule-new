import Foundation

class TimeFormatter {
    static let shared = TimeFormatter()
    
    private let formatter12Hour: DateFormatter
    private let formatter24Hour: DateFormatter
    
    private init() {
        formatter12Hour = DateFormatter()
        formatter12Hour.dateFormat = "h:mm a"
        
        formatter24Hour = DateFormatter()
        formatter24Hour.dateFormat = "HH:mm"
    }
    
    func formatTime(_ date: Date, use24Hour: Bool) -> String {
        if use24Hour {
            return formatter24Hour.string(from: date)
        } else {
            return formatter12Hour.string(from: date)
        }
    }
    
    func formatTimeRange(start: Date, end: Date, use24Hour: Bool) -> String {
        let startString = formatTime(start, use24Hour: use24Hour)
        let endString = formatTime(end, use24Hour: use24Hour)
        return "\(startString) - \(endString)"
    }
    
    func formatDuration(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
    
    func formatCountdown(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, timeInterval))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func formatTimeUntil(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
    
    func formatRelativeTime(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(abs(timeInterval) / 60)
        
        if timeInterval > 0 {
            if totalMinutes < 60 {
                return "in \(totalMinutes)m"
            } else {
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                if minutes > 0 {
                    return "in \(hours)h \(minutes)m"
                } else {
                    return "in \(hours)h"
                }
            }
        } else {
            if totalMinutes < 60 {
                return "\(totalMinutes)m ago"
            } else {
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                if minutes > 0 {
                    return "\(hours)h \(minutes)m ago"
                } else {
                    return "\(hours)h ago"
                }
            }
        }
    }
}