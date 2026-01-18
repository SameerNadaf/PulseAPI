//
//  Date+Extensions.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

extension Date {
    // MARK: - Relative Time
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var shortRelativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Formatting
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
    
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var fullDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // MARK: - Calculations
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var startOfHour: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.current.date(from: components) ?? self
    }
}

extension TimeInterval {
    /// Formats milliseconds for display (e.g., "123ms", "1.2s")
    var latencyString: String {
        if self < 1000 {
            return "\(Int(self))ms"
        } else {
            return String(format: "%.1fs", self / 1000)
        }
    }
    
    /// Duration string (e.g., "5m", "2h 30m", "1d 4h")
    var durationString: String {
        let seconds = Int(self)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            let remainingHours = hours % 24
            return remainingHours > 0 ? "\(days)d \(remainingHours)h" : "\(days)d"
        } else if hours > 0 {
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}
