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
    
    let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
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
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetable as NSObject
        
        try context.save()
    }
    
    func obtainTrackersCoreData() -> [TrackerCoreData] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            return trackersCoreData
        } catch {
            print("Error fetching trackers: \(error.localizedDescription)")
        }
        
        return []
    }
    
    func fetchTrackerById(_ id: UUID) -> [TrackerCoreData]? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            return trackersCoreData
        } catch {
            print("Error fetching trackers: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
