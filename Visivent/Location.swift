//
//  Location.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/15/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// location to coordinate mapping
@objc class Location : NSManagedObject {
    /// location string
    @NSManaged var location : String
    /// latitude
    @NSManaged var latitude : Double
    /// longitude
    @NSManaged var longitude : Double
    /// population
    @NSManaged var population : Int32
    
    /// initialize managed object
    /// :param: context db context
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    /// :param: context db context
    /// :param: location string
    /// :param: latitude
    /// :param: longitude
    /// :param: population
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, location: String, latitude: Double, longitude: Double, population: Int32) {
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.population = population
    }
}