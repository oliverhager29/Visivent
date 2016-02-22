//
//  USGSConvenience.swift
//  Visivent
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import UIKit
import Foundation
import CoreData

// MARK: - USGSClient (Convenient Resource Methods)
extension USGSClient {
    
    /// get earthquake events
    /// :param: period period
    /// :param: completionHandler completion handler to retrieve Event entities or handle error
    func getEarthquakeEvents(period: String, completionHandler: (result: [Event]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters : [String : AnyObject] = [USGSClient.URLKeys.Period: period]
        
        /* 2. Make the request */
        taskForGETMethod(parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            }
            else {
                if let featuresJson = JSONResult[USGSClient.JSONResponseKeys.Features] as? [[String : AnyObject]] {
                    var events : [Event] = []
                    for featureJson in featuresJson {
                        var id = ""
                        var longitude = 0.0
                        var latitude = 0.0
                        var title = ""
                        var summary = ""
                        //var category = ""
                        var location = ""
                        var timestamp = NSDate()
                        var magnitude = 0.1
                        id = featureJson[USGSClient.JSONResponseKeys.Id] as! String
                        if let geometryJson = featureJson[USGSClient.JSONResponseKeys.Geometry] {
                            let coordinatesJson = geometryJson[USGSClient.JSONResponseKeys.Coordinates] as! [AnyObject]
                            longitude = coordinatesJson[0] as! Double
                            latitude = coordinatesJson[1] as! Double
                        
                        if let propertiesJson = featureJson[USGSClient.JSONResponseKeys.Properties] as? [String : AnyObject] {
                            title = propertiesJson[USGSClient.JSONResponseKeys.Title] as! String
                            if let mag = propertiesJson[USGSClient.JSONResponseKeys.Magnitude] as? Double {
                                if mag > 0.0 {
                                    magnitude = mag
                                }
                            }
                            let tsunami = propertiesJson[USGSClient.JSONResponseKeys.Tsunami] as! Int
                            var tsunamiStr : String!
                            if tsunami == 0 {
                                tsunamiStr = "no"
                            }
                            else {
                                tsunamiStr = "yes"
                            }
                            summary = "Magnitude: \(magnitude), Tsunami: \(tsunamiStr)"
                            //category = propertiesJson[USGSClient.JSONResponseKeys.Type] as! String
                            let milliSeconds = propertiesJson[USGSClient.JSONResponseKeys.Time] as! Double
                            let seconds = milliSeconds / 1000.0
                            timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(seconds))
                            }
                        }
                        if magnitude >= self.clientConfig.usgsConfig.minMagnitude {
                            var weight = Double(magnitude) / Double(10.0)
                            if weight > 1.0 {
                                weight = 1.0
                            }
                            let privateContext = NSManagedObjectContext(
                                concurrencyType: .PrivateQueueConcurrencyType)
                            privateContext.persistentStoreCoordinator =
                                CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
                            privateContext.performBlockAndWait {
                                events.append(EventRepository.createEvent(privateContext, id: id, title: title, summary: summary, location: location, latitude: latitude, longitude: longitude, weight: weight, timestamp: timestamp, category: self.getCategory(privateContext, magnitude: magnitude), dataSource: EventRepository.getDataSourceById(privateContext, id: DataSource.USGSDataSourceId)!))
                                do {
                                    try privateContext.save()
                                }
                                catch {
                                    LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating earth quake event: \(error)")
                                }
                            }
                        }
                    }
                    while events.count < featuresJson.count {
                            
                    }
                    
                    completionHandler(result: events, error: nil)
            }
            else {
                    completionHandler(result: nil, error: NSError(domain: "getEarthquakeEvents parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getEarthquakeEvents"]))
                }
            }
        }
    }
    
    /// get category for earthquake magnitude
    /// :param: context db context
    /// :param: magnitude earthquake magnitude
    /// :returns: category
    func getCategory(context: NSManagedObjectContext, magnitude: Double) -> MapCategory {
        if magnitude < 0.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory0Id)!
        }
        else if magnitude < 1.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory1Id)!
        }
        else if magnitude < 2.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory2Id)!
        }
        else if magnitude < 3.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory3Id)!
        }
        else if magnitude < 4.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory4Id)!
        }
        else if magnitude < 5.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory5Id)!
        }
        else if magnitude < 6.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory6Id)!
        }
        else if magnitude < 7.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory7Id)!
        }
        else if magnitude < 8.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory8Id)!
        }
        else if magnitude < 9.5 {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory9Id)!
        }
        else {
            return EventRepository.getCategoryById(context, id: MapCategory.EarthquakeCategory10Id)!
        }
    }
}