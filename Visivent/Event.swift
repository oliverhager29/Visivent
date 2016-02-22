//
//  Event.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/22/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData
/// persistent event (e.g. Reuters News event, USGS earthquake event, GVP volcano activity, Twitter message)
@objc class Event : NSManagedObject {
    /// unique identifier
    @NSManaged var id : String
    /// title
    @NSManaged var title : String
    /// textual summary of event
    @NSManaged var summary : String
    /// location string
    @NSManaged var location : String
    /// latitude
    @NSManaged var latitude : Double
    /// longitude
    @NSManaged var longitude : Double
    /// weight for heat map (from 0 to 1.0)
    @NSManaged var weight : Double
    /// when event occured
    @NSManaged var timestamp : NSDate
    /// category of event
    @NSManaged var category : MapCategory
    /// data source where event is read from
    @NSManaged var dataSource : DataSource
    
    /// initialize managed object
    /// :param: entity entity
    /// :param: context db context
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    /// :param: context db context
    /// :param: id unique identifier
    /// :param: title title
    /// :param: summary textual summary of event
    /// :param: location location string
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: weight weight for heat map (from 0 to 1.0)
    /// :param: timestamp when event occured
    /// :param: category category of event
    /// :param: dataSource data source where event is read from
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, id: String, title: String, summary: String, location: String, latitude: Double, longitude: Double, weight: Double, timestamp: NSDate, category: MapCategory, dataSource: DataSource) {
        let entity =  NSEntityDescription.entityForName("Event", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.title = title
        self.summary = summary
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.category = category
        self.dataSource = dataSource
        self.weight = weight
    }
}