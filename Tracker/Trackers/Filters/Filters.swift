//
//  Filters.swift
//  Tracker
//
//  Created by Pavel Bobkov on 20.10.2024.
//

import Foundation

enum Filters: String, Codable {
    case all = "allTrackers"
    case today = "trackersForToday"
    case completed = "completedTrackers"
    case notCompleted = "notCompletedTrackers"
    
    func localised() -> String {
        NSLocalizedString(self.rawValue, comment: "Filters")
    }
}
