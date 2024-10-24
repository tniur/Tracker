//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Bobkov on 29.09.2024.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
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
    
    func addNewTracker(_ tracker: Tracker, _ category: TrackerCategory) throws {
        try trackerCategoryStore.addTrackerToCategory(category: category, tracker: tracker)
        
        try context.save()
    }
    
    func obtainTrackersCoreData() -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            let trackers = getTrackersFromTrackersCoreData(trackersCoreData: trackersCoreData)
            return trackers
        } catch {
            print("Error fetching trackers: \(error.localizedDescription)")
        }
        
        return []
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let tracker = try getTrackerById(tracker.id) else { return }
        context.delete(tracker)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, _ category: TrackerCategory? = nil) throws {
        guard let trackerCoreData = try getTrackerById(tracker.id) else { return }
        
        var categoryCoreData = trackerCoreData.category
        
        if let category {
            let fetchRequest = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
            fetchRequest.fetchLimit = 1
            let categoriesCoreData = try context.fetch(fetchRequest)
            categoryCoreData = categoriesCoreData.first
        }
        
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetable as NSObject
        trackerCoreData.category = categoryCoreData
        trackerCoreData.isPinned = tracker.isPinned
        try context.save()
    }
    
    func getTrackerCategory(for tracker: Tracker) throws -> TrackerCategory? {
        let trackerCoreData = try getTrackerById(tracker.id)
        
        guard let category = trackerCoreData?.category,
              let categoryTitle = category.title else { return nil }
        
        return try trackerCategoryStore.getCategory(by: categoryTitle)
    }
    
    private func getTrackerById(_ id: UUID) throws -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let tracker = try context.fetch(fetchRequest)
        return tracker.first
    }
    
    private func getTrackersFromTrackersCoreData(trackersCoreData: [TrackerCoreData]) -> [Tracker] {
        var trackers: [Tracker] = []
        trackersCoreData.forEach {
            guard let id = $0.id,
                  let name = $0.name,
                  let color = $0.color as? UIColor,
                  let emoji = $0.emoji,
                  let timetable = $0.timetable as? [WeekDay] else { return }
            
            let tracker = Tracker(
                id: id,
                name: name,
                color: color,
                emoji: emoji,
                timetable: timetable,
                isPinned: $0.isPinned
            )
            trackers.append(tracker)
        }
        return trackers
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
