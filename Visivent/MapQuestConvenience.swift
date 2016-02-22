//
//  MapQuestConvenience.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/29/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

// MARK: - MapQuestClient (Convenient Resource Methods)

extension MapQuestClient {
    
    /// get coordinates for a location string (we use MapQuest because of rate limits in Apple's CLGeoCoder)
    /// :param: location location string
    /// :param: completionHandler completion handler to retrieve coordinates (two Double values) entities or handle error
    func getCoordinates(location: String, completionHandler: (result: [String: Double]?, error: NSError?) -> Void) {
        let privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator =
            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
        var coordinates : CLLocationCoordinate2D? = nil
        privateContext.performBlockAndWait {
            coordinates = EventRepository.getCoordinatesByLocation(privateContext, location: location)
//            do {
//                try privateContext.save()
//            }
//            catch {
//                LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error looking up coordinates: \(error)")
//            }
        }
        if coordinates != nil {
                completionHandler(result: [MapQuestClient.JSONResponseKeys.Lat : coordinates!.latitude, MapQuestClient.JSONResponseKeys.Lng : coordinates!.longitude], error: nil)
            return
        }
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters : [String : AnyObject] =
            [
                MapQuestClient.URLKeys.ApiKey: config!.apiKey,
                MapQuestClient.URLKeys.Location: location
            ]
    
        
        /* 2. Make the request */
        taskForGETMethod(parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            }
            else {
                if let resultsJson = JSONResult[MapQuestClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    var coordinates : [String: Double] = [:]
                    for resultJson in resultsJson {
                        if let locationsJson = resultJson[MapQuestClient.JSONResponseKeys.Locations] as? [[String : AnyObject]] {
                            if !locationsJson.isEmpty {
                                let locationJSON = locationsJson.first
                                if let displayLatLngJSON = locationJSON![MapQuestClient.JSONResponseKeys.DisplayLatLng] as? [String : AnyObject] {
                                    let latitude = displayLatLngJSON[MapQuestClient.JSONResponseKeys.Lat] as! Double
                                    let longitude = displayLatLngJSON[MapQuestClient.JSONResponseKeys.Lng] as! Double
                                    coordinates =
                                    [
                                        MapQuestClient.JSONResponseKeys.Lat : latitude,
                                        MapQuestClient.JSONResponseKeys.Lng : longitude
                                    ]
                                    let privateContext = NSManagedObjectContext(
                                        concurrencyType: .PrivateQueueConcurrencyType)
                                    privateContext.persistentStoreCoordinator =
                                        CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
                                    privateContext.performBlockAndWait {
                                        EventRepository.createLocation(privateContext, location: location.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), latitude: latitude, longitude: longitude, population: Int32.max)
                                        do {
                                            try privateContext.save()
                                        }
                                        catch {
                                            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating location: \(error)")
                                        }
                                    }
                                }
                            }
                    }
                    completionHandler(result: coordinates, error: nil)
                    }
                }
                else {
                    completionHandler(result: nil, error: NSError(domain: "getCoordinates parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getCoordinates"]))
                }
            }
        }
    }
}