//
//  DataSource.swift
//  Visivent
//
//  Created by OLIVER HAGER on 12/2/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData
/// Event data source
@objc class DataSource : NSManagedObject {
    /// name of USGS data source
    static let USGSDataSourceName = "USGS"
    /// id of USGS data source
    static let USGSDataSourceId = 1
    /// URL of USGS data source
    static let USGSUrl = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php"
    /// name of Twitter data source
    static let TwitterDataSourceName = "Twitter"
    /// id of Twitter data source
    static let TwitterDataSourceId = 2
    /// URL of Twitter data source
    static let TwitterUrl = "https://dev.twitter.com/rest/public/timelines"
    /// name of Reuters News data source
    static let ReutersDataSourceName = "Reuters"
    /// id of Reuters News data source
    static let ReutersDataSourceId = 3
    /// URL of Reuter News Feed
    static let ReutersUrl = "http://www.reuters.com/tools/rss"
    /// name of GVP data source
    static let GVPDataSourceName = "GVP"
    /// id of GVP data source
    static let GVPDataSourceId = 4
    /// URL of GVP
    static let GVPUrl = "http://volcano.si.edu/reports_weekly.cfm#"
    
    /// id of data source
    @NSManaged var id : Int
    /// name of data source
    @NSManaged var name : String
    /// name of data source
    @NSManaged var url : String
    
    /// initialize managed object
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    /// :param: id id of data source
    /// :param: name name of data source
    /// :param: url link to data source
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, id: Int, name: String, url: String) {
        let entity =  NSEntityDescription.entityForName("DataSource", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.name = name
        self.url = url
    }
}
