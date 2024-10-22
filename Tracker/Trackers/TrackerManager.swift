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
    func getCurrentDate() -> Date
    func getSearchedWord() -> String?
    func getFilter() -> Filters
}

final class TrackerManager {
    
    // MARK: - Properties
    
    weak var delegate: TrackerManagerDelegate?
    
    private var allTrackersCount: Int = 0
    
    private var filtredCategories: [TrackerCategory] = []
    
    private let trackerStore = TrackerStore()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Life-Cycle
    
    init() {
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        filterCategories()
    }
    
    // MARK: - Methods
    
    func getNumbersOfCategories() -> Int {
        filtredCategories.count
    }
    
    func getNumbersOfTrackersInCategory(in section: Int) -> Int {
        filtredCategories[section].trackers.count
    }
    
    func getAllTrackersCount() -> Int {
        allTrackersCount
    }
    
    func getCategoryTitle(in section: Int) -> String {
        filtredCategories[section].title
    }
    
    func getCategory(by indexPath: IndexPath, for isPinned: Bool = false) -> TrackerCategory {
        if isPinned {
            do {
                let category = try trackerStore.getTrackerCategory(for: filtredCategories[indexPath.section].trackers[indexPath.row])
                guard let category else { return filtredCategories[indexPath.section] }
                return category
            } catch {
                print("Error fetching category: \(error.localizedDescription)")
            }
        }
        
        return filtredCategories[indexPath.section]
    }
    
    func getTracker(by indexPath: IndexPath) -> Tracker {
        filtredCategories[indexPath.section].trackers[indexPath.row]
    }
    
    func filterCategories() {
        do {
            let categories = try trackerCategoryStore.getCategories()
            guard let weekDay = delegate?.getCurrentWeekDay(),
                  let currentDate = delegate?.getCurrentDate() else { return }
            let searchedWord = delegate?.getSearchedWord()?.lowercased()
            let filter = delegate?.getFilter()
            
            allTrackersCount = categories.flatMap { $0.trackers }
                .filter { $0.timetable.isEmpty || $0.timetable.contains(weekDay) }
                .count
            
            var pinnedTrackers: [Tracker] = []
            
            let filteredCategories = categories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    if (tracker.timetable.isEmpty || tracker.timetable.contains(weekDay))
                        && (tracker.name.lowercased().contains(searchedWord ?? "") || (searchedWord == nil))
                        && (filter == .all || filter == .today
                            || (filter == .completed && trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate))
                            || (filter == .notCompleted && !trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate)))
                        && tracker.isPinned {
                        pinnedTrackers.append(tracker)
                    }
                    
                    return (tracker.timetable.isEmpty || tracker.timetable.contains(weekDay))
                    && (tracker.name.lowercased().contains(searchedWord ?? "") || (searchedWord == nil))
                    && (filter == .all || filter == .today
                        || (filter == .completed && trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate))
                        || (filter == .notCompleted && !trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate)))
                    && !tracker.isPinned
                }
                
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            
            if !pinnedTrackers.isEmpty {
                filtredCategories = [TrackerCategory(title: NSLocalizedString("pinned", comment: "Pinned trackers"), trackers: pinnedTrackers)] + filteredCategories
            } else {
                filtredCategories = filteredCategories
            }
            
            delegate?.didUpdate()
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("Error deleting tracker: \(error.localizedDescription)")
        }
    }
    
    func changeTrackerPinState(for tracker: Tracker, isPinned: Bool) {
        do {
            let pinnedTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, timetable: tracker.timetable, isPinned: isPinned)
            try trackerStore.updateTracker(pinnedTracker)
        } catch {
            print("Error pinning tracker: \(error.localizedDescription)")
        }
    }
}

extension TrackerManager: TrackerCategoryStoreDelegate, TrackerStoreDelegate {
    func didUpdate() {
        filterCategories()
    }
}
