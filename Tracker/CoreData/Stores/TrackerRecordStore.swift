//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Bobkov on 29.09.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    
    private let trackerStore = TrackerStore()
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error getting AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Methods
    
    func tryAddNewRecord(_ trackerId: UUID, date: Date) throws {
        if isRecordExists(trackerId: trackerId, date: date) {
            guard let record = try getRecord(byId: trackerId, date: date) else { return }
            try deleteRecord(record)
        } else {
            try addNewRecord(trackerId, date: date)
        }
    }
    
    func addNewRecord(_ trackerId: UUID, date: Date) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = date
        trackerRecordCoreData.trackerId = trackerId
        
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        
        try context.save()
    }
    
    func getRecord(byId id: UUID, date: Date) throws -> TrackerRecordCoreData? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@",
                                             id as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let record = try context.fetch(fetchRequest)
            return record.first
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return nil
        }
    }
    
    func countRecordsForTracker(byId id: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", id as CVarArg)
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return 0
        }
    }
    
    func isRecordExists(trackerId id: UUID, date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return false }
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@",
                                             id as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return false
        }
    }
}
