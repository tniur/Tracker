//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.10.2024.
//

import AppMetricaCore

enum Event: String {
    case open, close, click
}

enum Screen: String {
    case main = "Main"
}

enum Item: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    static func activate() {
        let configuration = AppMetricaConfiguration(apiKey: "c82bbc75-c3af-446c-888b-d66d192bf3eb")
        AppMetrica.activate(with: configuration!)
    }
    
    static func report(event: Event, screen: Screen, item: Item?) {
        var parameters: [AnyHashable: Any] = ["screen": screen.rawValue]
        if let item {
            parameters["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters) { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
