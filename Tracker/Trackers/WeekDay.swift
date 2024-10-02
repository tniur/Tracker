//
//  WeekDay.swift
//  Tracker
//
//  Created by Pavel Bobkov on 25.09.2024.
//

enum WeekDay: String, Codable {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
    
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
