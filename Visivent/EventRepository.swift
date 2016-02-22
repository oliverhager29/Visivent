//
//  EventRepository.swift
//  Visivent
//
//  Created by OLIVER HAGER on 12/1/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// Encapsulates all db operations
class EventRepository {
    /// USGS data source
    static var usgsDataSource: DataSource!
    /// GVP data source
    static var gvpDataSource: DataSource!
    /// Reuters News data spurce
    static var reutersDataSource: DataSource!
    /// Twitter data source
    static var twitterDataSource: DataSource!
    
    /// shared managed object context
    static var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    /// singelton instance
    static var sharedInstance: EventRepository {
        struct Static {
            static let instance = EventRepository()
        }
        // create/read data sources
        if usgsDataSource == nil {
            if let dataSource = EventRepository.getDataSourceById(sharedContext, id: DataSource.USGSDataSourceId) {
                usgsDataSource = dataSource
            }
            else {
                EventRepository.createDataSource(sharedContext, id: DataSource.USGSDataSourceId)
            }
        }
        if gvpDataSource == nil {
            if let dataSource = EventRepository.getDataSourceById(sharedContext, id: DataSource.GVPDataSourceId) {
                gvpDataSource = dataSource
            }
            else {
                EventRepository.createDataSource(sharedContext, id: DataSource.GVPDataSourceId)
            }
        }
        if reutersDataSource == nil {
            if let dataSource = EventRepository.getDataSourceById(sharedContext, id: DataSource.ReutersDataSourceId) {
                reutersDataSource = dataSource
            }
            else {
                EventRepository.createDataSource(sharedContext, id: DataSource.ReutersDataSourceId)
            }
        }
        if twitterDataSource == nil {
            if let dataSource = EventRepository.getDataSourceById(sharedContext, id: DataSource.TwitterDataSourceId) {
                twitterDataSource = dataSource
            }
            else {
                EventRepository.createDataSource(sharedContext, id: DataSource.TwitterDataSourceId)
            }
        }

        if EventRepository.getCategoryById(sharedContext, id: MapCategory.TwitterCategoryId) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.TwitterCategoryId)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.NewsCategoryId) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.NewsCategoryId)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategoryId) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategoryId)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory0Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory0Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory1Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory1Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory2Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory2Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory3Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory3Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory4Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory4Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory5Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory5Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory6Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory6Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory7Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory7Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory8Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory8Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory9Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory9Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.EarthquakeCategory10Id) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.EarthquakeCategory10Id)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.VolcanicActivityCategoryId) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.VolcanicActivityCategoryId)
        }
        if EventRepository.getCategoryById(sharedContext, id: MapCategory.VolcanoLocationCategoryId) == nil {
            EventRepository.createCategory(sharedContext, id: MapCategory.VolcanoLocationCategoryId)
        }
        EventRepository.save()
        return Static.instance
    }
    
    /// save data in shared db context
    static func save() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    /// create location (i.e. city/country/time zone to coordinate)
    /// :param: context db context
    /// :param: location location string
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: population population (of city)
    static func createLocation(context: NSManagedObjectContext, location: String, latitude: Double, longitude: Double, population: Int32) {
        var locationObject : Location? = Location(insertIntoManagedObjectContext: context, location: location
            , latitude: latitude, longitude: longitude, population: population)
        locationObject = nil
    }
    
    /// create event (e.g. Reuters News event, USGS earthquake event, GVP volcano activity, Twitter message)
    /// :returns created event
    /// :param: context db context
    /// :param: id unique event id
    /// :param: title title
    /// :param: summary textual event summary
    /// :param: location location string
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: weight weight for heat map (from 0 to 1.0)
    /// :param: timestamp when event happened
    /// :param: category event category
    /// :param: dataSource data source where event is read from
    static func createEvent(context: NSManagedObjectContext, id: String, title: String, summary: String, location: String, latitude: Double, longitude: Double, weight: Double, timestamp: NSDate, category: MapCategory, dataSource: DataSource) -> Event {
        var event : Event!
        event = Event(insertIntoManagedObjectContext: context, id: id, title: title, summary: summary, location: location, latitude: latitude, longitude: longitude, weight: weight, timestamp: timestamp, category: category, dataSource: dataSource)
        do {
            try context.save()
        }
        catch {
            context.reset()
            event = nil
        }
        return event
    }
    
    /// change event coorindates
    /// :param: context db context
    /// :param: id unique event id
    /// :param: latitude new latitude to set
    /// :param: longitude new longitude to set
    static func changeEventCoordinates(context: NSManagedObjectContext, id: String, latitude: Double, longitude: Double) {
            if let event = getEventById(context, id: id) {
                event.latitude = latitude
                event.longitude = longitude
            }
    }
    /// get event by id
    /// :param: context db context
    /// :param: id unique event id
    /// :returns: found event
    static func getEventById(context: NSManagedObjectContext, id: String) -> Event? {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        do {
            if let result = try context.executeFetchRequest(fetchRequest).first as? Event {
                return result
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getEventById(): \(error)")
        }
        return nil
    }

    /// lookup coordinates for location string (e.g. city)
    /// :param: context db context
    /// :param: location location string
    /// :returns: coordinates (if exists)
    static func getCoordinatesByLocation(context: NSManagedObjectContext, location: String) -> CLLocationCoordinate2D? {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.predicate = NSPredicate(format: "location == %@", location.lowercaseString.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        fetchRequest.fetchLimit = 1
        do {
            if let result = try context.executeFetchRequest(fetchRequest).first as? Location {
                return CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getCoordinateByLocation(): \(error)")
        }
        return nil
    }
    
    /// get location by location string
    /// :param: context db context
    /// :param: location location string
    /// :returns: found location (if exists)
    static func getLocationByLocationString(context: NSManagedObjectContext, location: String) -> Location? {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.predicate = NSPredicate(format: "location == %@", location.lowercaseString.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        fetchRequest.fetchLimit = 1
        do {
            if let result = try context.executeFetchRequest(fetchRequest).first as? Location {
                return result
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getCoordinateByLocation(): \(error)")
        }
        return nil
    }
    
    /// find all events
    /// :returns: all events
    static func findAllEvents() -> [Event] {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            return results as! [Event]
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in findEvents(): \(error)")
        }
        return []
    }
    
    /// find events by criteria
    /// :param: dataSourceIds events from the passed data sources
    /// :param: fromDate start of time interval to consider
    /// :param: toDate end of time interval to consider    
    /// :param: hasLocation event has location
    /// :returns: found events
    static func findEvents(context: NSManagedObjectContext, dataSourceIds: [Int], fromDate: NSDate?, toDate: NSDate?, hasLocation: Bool) -> [Event] {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        var whereClause = ""
        var isFirst = true
        var args : [AnyObject]? = []
        if !dataSourceIds.isEmpty {
            if isFirst {
                isFirst = false
            }
            else {
                whereClause += " AND "
            }
            for(var i=0; i<dataSourceIds.count; i++) {
                if i == 0 {
                    whereClause += " ("
                }
                args!.append(NSInteger(dataSourceIds[i]))
                whereClause += "dataSource.id == %ld"
                if i < dataSourceIds.count-1 {
                    whereClause += " OR "
                }
                else if i == dataSourceIds.count-1 {
                    whereClause += ") "
                }
            }
        }
        else {
            return []
        }
        if fromDate != nil {
            if isFirst {
                isFirst = false
            }
            else {
                whereClause += " AND "
            }
            args!.append(fromDate!)
            whereClause += "timestamp >= %@"
        }
        if toDate != nil {
            if isFirst {
                isFirst = false
            }
            else {
                whereClause += " AND "
            }
            args!.append(toDate!)
            whereClause += "timestamp <= %@"
        }
        
        fetchRequest.predicate = NSPredicate(format: whereClause, argumentArray: args)
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            return results as! [Event]
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in findEvents(): \(error)")
        }
        if isFirst {
            isFirst = false
        }
        else {
                whereClause += " AND "
            }
            args!.append(Double.NaN)
        if hasLocation {
            whereClause += "latitude == %ld"
        }
        else {
            whereClause += "latitude != %ld"
        }
        return []
    }
    
    /// get data source by id
    /// :param: context db context
    /// :param: id data source id
    /// :returns: found data source
    static func getDataSourceById(context: NSManagedObjectContext, id: Int) -> DataSource? {
        let fetchRequest = NSFetchRequest(entityName: "DataSource")
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            var dataSources = results as! [DataSource]
            if dataSources.isEmpty {
                return nil
            }
            else {
                return dataSources[0]
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getDataSourceById(): \(error)")
        }
        return nil
    }
    
    /// create data source
    /// :param: context db context
    /// :param: data source id
    static func createDataSource(context: NSManagedObjectContext, id: Int) {
        if getDataSourceById(context, id: id) == nil {
            if DataSource.ReutersDataSourceId == id {
                reutersDataSource = DataSource(insertIntoManagedObjectContext: context, id: DataSource.ReutersDataSourceId, name: DataSource.ReutersDataSourceName, url: DataSource.ReutersUrl)
                save()
            }
            else if DataSource.TwitterDataSourceId == id {
                twitterDataSource = DataSource(insertIntoManagedObjectContext: context, id: DataSource.TwitterDataSourceId, name: DataSource.TwitterDataSourceName, url: DataSource.TwitterUrl)
                save()
            }
            else if DataSource.USGSDataSourceId == id {
                usgsDataSource = DataSource(insertIntoManagedObjectContext: context, id: DataSource.USGSDataSourceId, name: DataSource.USGSDataSourceName, url: DataSource.USGSUrl)
                save()
            }
            else if DataSource.GVPDataSourceId == id {
                gvpDataSource = DataSource(insertIntoManagedObjectContext: context, id: DataSource.GVPDataSourceId, name: DataSource.GVPDataSourceName, url: DataSource.GVPUrl)
                save()
            }
        }
    }
    
    /// Delete events of a certain data source that are older than maxHours in order to limit amount memory used by the SQLite DB
    /// :param: context db context
    /// :param: dataSourceId data source id
    /// :param: maxHours maximum number of hours to keep events
    static func truncateData(context: NSManagedObjectContext, dataSourceId: Int, maxHours: Int) {
        let now = NSDate()
        let maxDate = now.dateByAddingTimeInterval(NSTimeInterval(-1 * maxHours * 60 * 60))
        let eventsToDelete = self.findEvents(context, dataSourceIds: [dataSourceId], fromDate: nil, toDate: maxDate, hasLocation: Bool(true))
        for eventToDelete in eventsToDelete {
            context.deleteObject(eventToDelete)
        }
    }
    
    /// get category by id
    /// :param: context db context
    /// :param: id category id
    /// :returns: found category
    static func getCategoryById(context: NSManagedObjectContext, id: Int) -> MapCategory? {
        let fetchRequest = NSFetchRequest(entityName: "MapCategory")
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            var categories = results as! [MapCategory]
            if categories.isEmpty {
                return nil
            }
            else {
                return categories[0]
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getCategoryById(): \(error)")
        }
        return nil
    }
    
    /// get category by name
    /// :param: context db context
    /// :param: name category name
    /// :returns: found category
    static func getCategoryByName(context: NSManagedObjectContext, name: String) -> MapCategory? {
        let fetchRequest = NSFetchRequest(entityName: "MapCategory")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            var categories = results as! [MapCategory]
            if categories.isEmpty {
                return nil
            }
            else {
                return categories[0]
            }
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error in getCategoryByName(): \(error)")
        }
        return nil
    }
    
    /// create category
    /// :param: context db context
    /// :param: category id
    static func createCategory(context: NSManagedObjectContext, id: Int) {
        do {
            if getCategoryById(context, id: id) == nil {
                if MapCategory.NewsCategoryId == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.NewsCategoryId, name: MapCategory.NewsCategoryName, standardPinColor: MapCategory.NewsStandardPinColor, customizedIconFileName: MapCategory.NewsCustomizedIconFileName)
                }
                else if MapCategory.TwitterCategoryId == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.TwitterCategoryId, name: MapCategory.TwitterCategoryName, standardPinColor: MapCategory.TwitterStandardPinColor, customizedIconFileName: MapCategory.TwitterCustomizedIconFileName)
                }
                else if MapCategory.VolcanicActivityCategoryId == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.VolcanicActivityCategoryId, name: MapCategory.VolcanicActivityCategoryName, standardPinColor: MapCategory.VolcanicActivityStandardPinColor, customizedIconFileName: MapCategory.VolcanicActivityCustomizedIconFileName)
                }
                else if MapCategory.VolcanoLocationCategoryId == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.VolcanoLocationCategoryId, name: MapCategory.VolcanoLocationCategoryName, standardPinColor: MapCategory.VolcanoLocationStandardPinColor, customizedIconFileName: MapCategory.VolcanoLocationCustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory0Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory0Id, name: MapCategory.EarthquakeCategory0Name, standardPinColor: MapCategory.EarthquakeCategory0StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory0CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory1Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory1Id, name: MapCategory.EarthquakeCategory1Name, standardPinColor: MapCategory.EarthquakeCategory1StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory1CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory2Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory2Id, name: MapCategory.EarthquakeCategory2Name, standardPinColor: MapCategory.EarthquakeCategory2StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory2CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory3Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory3Id, name: MapCategory.EarthquakeCategory3Name, standardPinColor: MapCategory.EarthquakeCategory3StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory3CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory4Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory4Id, name: MapCategory.EarthquakeCategory4Name, standardPinColor: MapCategory.EarthquakeCategory4StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory4CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory5Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory5Id, name: MapCategory.EarthquakeCategory5Name, standardPinColor: MapCategory.EarthquakeCategory5StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory5CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory6Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory6Id, name: MapCategory.EarthquakeCategory6Name, standardPinColor: MapCategory.EarthquakeCategory6StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory6CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory7Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory7Id, name: MapCategory.EarthquakeCategory7Name, standardPinColor: MapCategory.EarthquakeCategory7StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory7CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory8Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory8Id, name: MapCategory.EarthquakeCategory8Name, standardPinColor: MapCategory.EarthquakeCategory8StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory8CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory9Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory9Id, name: MapCategory.EarthquakeCategory9Name, standardPinColor: MapCategory.EarthquakeCategory9StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory9CustomizedIconFileName)
                }
                else if MapCategory.EarthquakeCategory10Id == id {
                    let category = MapCategory(insertIntoManagedObjectContext: context, id: MapCategory.EarthquakeCategory10Id, name: MapCategory.EarthquakeCategory10Name, standardPinColor: MapCategory.EarthquakeCategory10StandardPinColor, customizedIconFileName: MapCategory.EarthquakeCategory10CustomizedIconFileName)
                }
            }
            try context.save()
        }
        catch {
            LogUtil.alert(LogUtil.ERROR, title: "DB Error while creating category", message: "\(error)")
        }
    }
}