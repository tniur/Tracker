//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Bobkov on 29.09.2024.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error getting AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext:  context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.fetchedResultsController = fetchedResultsController
        try? fetchedResultsController.performFetch()
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
    
    // MARK: - Methods
    
    func addTrackerToCategory(category: TrackerCategory, tracker: Tracker) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        fetchRequest.fetchLimit = 1
        let categoriesCoreData = try context.fetch(fetchRequest)
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetable as NSObject
        trackerCoreData.isPinned = tracker.isPinned
        
        trackerCoreData.category = categoriesCoreData.first
    }
    
    func getCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(fetchRequest)
        let categories = getCategoriesFromCategoriesCoreData(categoriesCoreData: categoriesCoreData)
        return categories
    }
    
    func tryAddNewCategory(with title: String) throws {
        if !isCategoryExists(with: title) {
            try addNewCategory(with: title)
        }
    }
    
    func getCategory(by title: String) throws -> TrackerCategory? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        let categoriesCoreData = try context.fetch(fetchRequest)
        
        guard let category = categoriesCoreData.first,
              let title = category.title,
              let trackersCoreData = category.trackers?.allObjects as? [TrackerCoreData] else { return nil }
        
        let trackers = getTrackersFromTrackersCoreData(trackersCoreData: trackersCoreData)
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func getCategoriesFromCategoriesCoreData(categoriesCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        categoriesCoreData.forEach {
            guard let title = $0.title,
                  let trackersCoreData = $0.trackers?.allObjects as? [TrackerCoreData] else { return }
            
            let trackers = getTrackersFromTrackersCoreData(trackersCoreData: trackersCoreData)
            
            categories.append(TrackerCategory(title: title, trackers: trackers))
        }
        return categories
    }
    
    private func getTrackersFromTrackersCoreData(trackersCoreData: [TrackerCoreData]) -> [Tracker] {
        var trackers: [Tracker] = []
        trackersCoreData.forEach {
            guard let id = $0.id,
                  let name = $0.name,
                  let color = $0.color as? UIColor,
                  let emoji = $0.emoji,
                  let timetable = $0.timetable as? [WeekDay] else { return }
            
            trackers.append(Tracker(id: id, name: name, color: color, emoji: emoji, timetable: timetable, isPinned: $0.isPinned))
        }
        return trackers
    }
    
    private func isCategoryExists(with title: String) -> Bool {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error fetching category: \(error.localizedDescription)")
            return false
        }
    }
    
    private func addNewCategory(with title: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = title
        
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
