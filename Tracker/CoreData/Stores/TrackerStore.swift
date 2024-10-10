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
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetable as NSObject
        
        try trackerCategoryStore.addTrackerToCategory(categoryTitle: category.title, tracker: trackerCoreData)
        
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

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
