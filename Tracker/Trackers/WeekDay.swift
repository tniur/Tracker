//
//  WeekDay.swift
//  Tracker
//
//  Created by Pavel Bobkov on 25.09.2024.
//

import Foundation

enum WeekDay: String, Codable {
    case monday = "monday.short"
    case tuesday = "tuesday.short"
    case wednesday = "wednesday.short"
    case thursday = "thursday.short"
    case friday = "friday.short"
    case saturday = "saturday.short"
    case sunday = "sunday.short"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "Week day")
    }
    
    static func getWeekDayFrom(dayName value: String) -> WeekDay? {
        switch value {
        case "Monday":
            return .monday
        case "Tuesday":
            return .tuesday
        case "Wednesday":
            return .wednesday
        case "Thursday":
            return .thursday
        case "Friday":
            return .friday
        case "Saturday":
            return .saturday
        case "Sunday":
            return .sunday
        default:
            return nil
        }
    }
}
