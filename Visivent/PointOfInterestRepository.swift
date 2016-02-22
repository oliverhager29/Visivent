//
//  PointOfInterestRepository.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/29/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// encapsulate point of interest db operations
class PointOfInterestRepository {
    /// shared managed object context
    static var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    /// singleton
    static var sharedInstance: EventRepository {
        struct Static {
            static let instance = EventRepository()
        }
        return Static.instance
    }
    /// save shared context
    static func save() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    /// create point of interest
    /// :param: context db context
    /// :param: name name
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: imageUrl image link
    /// :param: webcamUrl webcam link
    /// :param: summary textual summary
    /// :param: category category of POI
    static func createPointOfInterest(context: NSManagedObjectContext, name: String, latitude: Double, longitude: Double, imageUrl: String, webcamUrl: String, summary: String, category: MapCategory) {
        var poiObject : PointOfInterest? = PointOfInterest(insertIntoManagedObjectContext: context, name: name,latitude: latitude, longitude: longitude, imageUrl: imageUrl, webcamUrl: webcamUrl, summary: summary, category: category)
        poiObject = nil
    }

    /// find all points of interest
    /// :returns: found points of interest
    static func findAllPointOfInterests() -> [PointOfInterest] {
        let fetchRequest = NSFetchRequest(entityName: "PointOfInterest")
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            return results as! [PointOfInterest]
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in findPointOfInterest(): \(error)")
        }
        return []
    }
    
    /// get point of interest by name
    /// :param: context db context
    /// :param: name name of point of interest
    /// :returns: found point of interest (if exists)
    static func getPointOfInterestByName(context: NSManagedObjectContext, name: String) -> PointOfInterest? {
        let fetchRequest = NSFetchRequest(entityName: "PointOfInterest")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        do {
            if let result = try context.executeFetchRequest(fetchRequest).first as? PointOfInterest {
                return result
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getPointOfInterestByName(): \(error)")
        }
        return nil
    }
}
