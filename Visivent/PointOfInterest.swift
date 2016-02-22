//
//  PointOfInterest.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/29/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData
/// Point of interest (e.g. location of volcano with description, image and webcam link)
@objc class PointOfInterest : NSManagedObject {
    /// name
    @NSManaged var name : String
    /// latitude
    @NSManaged var latitude : Double
    /// longitude
    @NSManaged var longitude : Double
    /// image link
    @NSManaged var imageUrl : String
    /// webcam link
    @NSManaged var webcamUrl : String
    /// textual summary
    @NSManaged var summary : String
    // category of POI
    @NSManaged var category : MapCategory
    
    /// initialize managed object
    /// :param: context db context
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    /// :param: context db context
    /// :param: name name
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: imageUrl image link
    /// :param: webcamUrl webcam link
    /// :param: summary textual summary
    /// :param: category category of POI
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, name: String, latitude: Double, longitude: Double, imageUrl: String, webcamUrl: String, summary: String, category: MapCategory) {
        let entity =  NSEntityDescription.entityForName("PointOfInterest", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageUrl = imageUrl
        self.webcamUrl = webcamUrl
        self.summary = summary
        self.category = category
    }
}