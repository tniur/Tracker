//
//  TrackerManager.swift
//  Tracker
//
//  Created by Pavel Bobkov on 30.09.2024.
//

import UIKit

protocol TrackerManagerDelegate: AnyObject {
    func didUpdate()
    func getCurrentWeekDay() -> WeekDay?
}

final class TrackerManager {
    
    // MARK: - Properties
    
    weak var delegate: TrackerManagerDelegate?
    
    private var filtredTrackers: [Tracker] = []
    
    private let trackerStore: TrackerStore = TrackerStore()
    
    // MARK: - Life-Cycle
    
    init() {
        trackerStore.delegate = self
        filterTrackers()
    }
    
    // MARK: - Methods
    
    func getNumbersOfCategories() -> Int {
        return 1
    }
    
    func getNumbersOfTrackers() -> Int {
        return filtredTrackers.count
    }
    
    func getTracker(by indexPath: IndexPath) -> Tracker {
        return filtredTrackers[indexPath.row]
    }
    
    func filterTrackers() {
        let trackersCoreData = trackerStore.obtainTrackersCoreData()
        let trackers = getTrackersFromTrackersCoreData(trackersCoreData: trackersCoreData)
        
        var newFilteredTrackers: [Tracker] = []
        
        guard let weekDay = delegate?.getCurrentWeekDay() else { return }
        
        trackers.forEach {
            if $0.timetable.contains(weekDay) {
                newFilteredTrackers.append($0)
            } else if $0.timetable.isEmpty {
                newFilteredTrackers.append($0)
            }
        }
        
        filtredTrackers = newFilteredTrackers
        delegate?.didUpdate()
    }
    
    private func getTrackersFromTrackersCoreData(trackersCoreData: [TrackerCoreData]) -> [Tracker] {
        var trackers: [Tracker] = []
        trackersCoreData.forEach {
            guard let id = $0.id,
                  let name = $0.name,
                  let color = $0.color as? UIColor,
                  let emoji = $0.emoji,
                  let timetable = $0.timetable as? [WeekDay] else { return }
            
            trackers.append(Tracker(id: id, name: name, color: color, emoji: emoji, timetable: timetable))
        }
        return trackers
    }
}

extension TrackerManager: TrackerStoreDelegate {
    func didUpdate() {
        filterTrackers()
    }
}
