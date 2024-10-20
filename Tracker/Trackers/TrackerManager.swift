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
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Life-Cycle
    
    init() {
        trackerCategoryStore.delegate = self
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
            
            let filteredCategories = categories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    (tracker.timetable.isEmpty || tracker.timetable.contains(weekDay))
                    && (tracker.name.lowercased().contains(searchedWord ?? "") || (searchedWord == nil))
                    && (filter == .all || filter == .today
                        || (filter == .completed && trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate))
                        || (filter == .notCompleted && !trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate)))
                }
                
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            
            filtredCategories = filteredCategories
            delegate?.didUpdate()
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
}

extension TrackerManager: TrackerCategoryStoreDelegate {
    func didUpdate() {
        filterCategories()
    }
}
