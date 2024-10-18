//
//  StatisticsCategory.swift
//  Tracker
//
//  Created by Pavel Bobkov on 19.10.2024.
//

import Foundation

enum StatisticsCategory: String {
    case bestPeriod = "bestPeriod"
    case perfectDays = "perfectDays"
    case trackersCompleted = "trackersCompleted"
    case averageValue = "averageValue"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "Statistics category")
    }
}
