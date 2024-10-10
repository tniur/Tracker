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
    
    private var filtredCategories: [TrackerCategory] = []
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
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
    
    func getCategoryTitle(in section: Int) -> String {
        filtredCategories[section].title
    }
    
    func getTracker(by indexPath: IndexPath) -> Tracker {
        filtredCategories[indexPath.section].trackers[indexPath.row]
    }
    
    func filterCategories() {
        do {
            let categories = try trackerCategoryStore.getCategories()
            guard let weekDay = delegate?.getCurrentWeekDay() else { return }
            
            let filteredCategories = categories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.timetable.isEmpty || tracker.timetable.contains(weekDay)
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
