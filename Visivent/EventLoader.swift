//
//  EventLoader.swift
//  Visivent
//
//  Created by OLIVER HAGER on 12/3/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// loads events on a configurable schedule
class EventLoader {
    static var sharedInstance: EventLoader {
        return EventLoader()
    }
    
    /// client configuration
    var clientConfig : ClientConfig!
    
    /// initiate event loading with configurable start times and frequencies
    init() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        EventRepository.sharedInstance
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.rssConfig.startTime),
            target: self, selector: "loadReutersNewsEvents", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.usgsConfig.startTime),
            target: self, selector: "loadUSGSEvents", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.gvpConfig.startTime),
            target: self, selector: "loadGVPEvents", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.twitterConfig.startTime),
            target: self, selector: "loadTwitterEvents", userInfo: nil, repeats: false)
    }
    
    /// load Reuters News events
    @objc func loadReutersNewsEvents() {
        // Reuters
        if clientConfig.rssConfig.isDataCollectionEnabled {
            LogUtil.alert(LogUtil.INFO, title: "Reuters News", message: "Started loading Reuters News")
            let clonedTopics = NSMutableArray(array: clientConfig.rssConfig.topics)
            for elem in clonedTopics {
                let topic = elem as! String
                var rssClient : RSSClient? = RSSClient()
                var mutableParameters : [String : AnyObject] = [:]
                mutableParameters[RSSClient.ParameterKeys.Format] = RSSClient.ParameterConstants.XML
                rssClient!.taskForGETMethod(topic, parameters: mutableParameters, completionHandler: {
                    result, error in
                    if let error = error as NSError? {
                        LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error: \(error)")
                    }
                    LogUtil.alert(LogUtil.INFO, title: "Reuters News", message: "Finished loading Reuters News")
                })
                rssClient = nil
            }
        }
        /// schedule next load
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.rssConfig.refreshInterval),
            target: self, selector: "loadReutersNewsEvents", userInfo: nil, repeats: true)
    }
    
    /// load USGS earthquake events
    @objc func loadUSGSEvents() {
        // USGS
        if clientConfig.usgsConfig.isDataCollectionEnabled {
            LogUtil.alert(LogUtil.INFO, title: "USGS Earthquakes", message: "Started loading USGS Earthquakes")
            var usgsClient : USGSClient? = USGSClient.sharedInstance()
            usgsClient!.getEarthquakeEvents(USGSClient.Periods.allWeek, completionHandler: {
                result, error in
                if let error = error as NSError? {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error: \(error)")
                }
                //else if result != nil {
                //    EventRepository.save()
                //}
                LogUtil.alert(LogUtil.INFO, title: "USGS Earthquakes", message: "Finished loading USGS Earthquakes")
            })
            usgsClient = nil
        }
        /// schedule next load
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.usgsConfig.refreshInterval),
            target: self, selector: "loadUSGSEvents", userInfo: nil, repeats: true)
    }
    
    /// load GVP volcanic activity events
    @objc func loadGVPEvents() {
        // GVP
        if clientConfig.gvpConfig.isDataCollectionEnabled {
            LogUtil.alert(LogUtil.INFO, title: "GVP Volcanic Activities", message: "Started loading GVP Volcanic Activity")
            var gvpClient : GVPClient? = GVPClient.sharedInstance()
            gvpClient!.getVolcanoEvents({
                error in
                if let error = error as NSError? {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error: \(error)")
                }
            })
            gvpClient = nil
            LogUtil.alert(LogUtil.INFO, title: "GVP Volcanic Activities", message: "Finished loading GVP Volcanic Activity")
        }
        /// schedule next load
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.gvpConfig.refreshInterval),
            target: self, selector: "loadGVPEvents", userInfo: nil, repeats: true)
    }
    
    /// load Twitter messages
    @objc func loadTwitterEvents() {
        // Twitter
        LogUtil.alert(LogUtil.INFO, title: "Twitter messages", message: "Started loading Twitter messages")
        if clientConfig.twitterConfig.isDataCollectionEnabled {
            var twitterClient : TwitterClient? = TwitterClient()
            twitterClient!.getTwitterEventsUsingSwifter({
                error in
                dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
                    if error != nil {
                        LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "\(error)")
                    }
                    else {
                        var locations : [String] = []
                        var eventIds : [String] = []
                        let privateContext = NSManagedObjectContext(
                            concurrencyType: .PrivateQueueConcurrencyType)
                        privateContext.persistentStoreCoordinator =
                            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
                        privateContext.performBlockAndWait {
                            let events = EventRepository.findEvents(privateContext, dataSourceIds: [DataSource.TwitterDataSourceId], fromDate: nil, toDate: nil, hasLocation: false)
                            for event in events {
                                locations.append(event.location)
                                eventIds.append(event.id)
                            }
                            do {
                                try privateContext.save()
                                privateContext.reset()
                            }
                            catch {
                                LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Adding coordinates to twitter messages failed: \(error)")
                            }
                        }
                        let locationUtil = LocationUtil()
                        for (var i=0; i<eventIds.count; i++) {
                            autoreleasepool {
                                let eventId = eventIds[i]
                                let location = locations[i]
                                let coord = locationUtil.locate(location)
                                let latitude = coord[0]
                                let longitude = coord[1]
                                let privateContext = NSManagedObjectContext(
                                    concurrencyType: .PrivateQueueConcurrencyType)
                                privateContext.persistentStoreCoordinator =
                                    CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
                                privateContext.performBlockAndWait {
                                    EventRepository.changeEventCoordinates(privateContext, id: eventId, latitude: latitude, longitude: longitude)
                                    do {
                                        try privateContext.save()
                                        privateContext.reset()
                                    }
                                    catch {
                                        LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Adding coordinates to twitter messages failed: \(error)")
                                    }
                                }
                            }
                        }
                        LogUtil.alert(LogUtil.INFO, title: "Twitter messages", message: "Finished loading Twitter messages")
                    }
                }
            })
            twitterClient = nil
        }
        /// schedule next load
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.clientConfig.twitterConfig.refreshInterval),
            target: self, selector: "loadTwitterEvents", userInfo: nil, repeats: true)
    }
}