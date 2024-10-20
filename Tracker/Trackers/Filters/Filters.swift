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
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "trackersFilter")
        }
    }
    
    static func getFromUserDefaults() -> Filters {
        if let savedFilter = UserDefaults.standard.data(forKey: "trackersFilter") {
            do {
                return try JSONDecoder().decode(Filters.self, from: savedFilter)
            } catch {
                return .all
            }
        } else {
            return .all
        }
    }
}
