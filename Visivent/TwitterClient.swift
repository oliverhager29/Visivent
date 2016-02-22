//
//  TwitterClient.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/23/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import Social
import Accounts
import SwifteriOS
import MapKit
import CoreLocation
import CoreData

/// Twitter client to get a sense of communication activity in a region
class TwitterClient : NSObject {
    /// maximum number of Twitter message to read in a single poll
    let MaxCount = 3000
    /// maximum number of messages per invocation. There are as many invocations until MaxCount of messages has been reached
    let MaxPerInvocation = 100
    /// number of message to commit after (commit batch of messages)
    let NumberOfMessageInBatch = 50
    /// db context
    var privateContext : NSManagedObjectContext? = nil
    /// identifier for Twitter message poller which polls MaxPerInvocation messages iteratively from the Twitter server
    static let QueueIdentifier = "visivent.twitter.queue.identifier"
    /// serial exceution queue
    private var queue = dispatch_queue_create(TwitterClient.QueueIdentifier, DISPATCH_QUEUE_SERIAL)
    /// message counter
    private (set) var counter : Int = 0
    /// increment message counter
    func incrementCounter () {
        dispatch_sync(queue) {
            self.counter++
        }
    }
    /// using Swifter framerwork for authenticating to Twitter and read messages
    var swifter : Swifter!
    /// client configuration
    var clientConfig : ClientConfig!

    /// initialize Swifter framework, authenticate with Twitter (via Swifter) and initialize db context
    override init() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        swifter = Swifter(consumerKey: clientConfig.twitterConfig.consumerKey, consumerSecret: clientConfig.twitterConfig.consumerSecret)
        self.privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext!.persistentStoreCoordinator =
            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
        super.init()
    }
    /// deallocate Swift client, execution queue and save/reset db context
    deinit {
       self.swifter = nil
       self.clientConfig = nil
        self.queue = nil
        self.privateContext!.performBlockAndWait {
            do {
                try self.privateContext!.save()
                self.privateContext!.reset()
            }
            catch {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error creating twitter messages: \(error)")
            }
        }
        self.privateContext = nil
    }
    /// get events using Swifter
    /// :param: completionHandler handler error
    func getTwitterEventsUsingSwifter(completionHandler: (error: NSError!) -> Void){
        swifter.getSearchTweetsWithQuery(TwitterClient.URLKeys.SearchCriteria, geocode: nil, lang: nil, locale: nil, resultType: nil, count: MaxPerInvocation, until: nil, sinceID: nil, maxID: nil, includeEntities: true, callback: nil,
            success: { (statuses, searchMetadata) -> Void in
                self.continueOrComplete(statuses, searchMetadata: searchMetadata, completionHandler: completionHandler)
            },
            failure: {
                error in
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "\(error)")
            })
    }
    /// continue polling message until MaxCount of message is reached
    /// :param: statuses holder array for polled Twitter messages in JSON
    /// :param: searchMetadata contains sinceId to enable paging
    /// :param: completionHandler handles errors
    func continueOrComplete(statuses: [SwifteriOS.JSONValue]?, searchMetadata:  Dictionary<String, JSONValue>?, completionHandler: (error: NSError!) -> Void) {
        if let statuses = statuses as [SwifteriOS.JSONValue]? {
            for status in statuses {
                var summary = StringUtil.EmptyString
                var title = StringUtil.EmptyString
                var id = StringUtil.EmptyString
                var timestamp : NSDate = NSDate()
                var category = StringUtil.EmptyString
                var location = StringUtil.EmptyString
                if let dict = status.object as [String : SwifteriOS.JSONValue]? {
                    if let description = dict[TwitterClient.JSONResponseKeys.Text]?.string {
                        summary = description
                        title = description
                    }
                    if let idStr = dict[TwitterClient.JSONResponseKeys.IdStr]?.string {
                        id = idStr
                    }
                    //Thu Nov 26 06:21:38 +0000 2015
                    if let timestampStr = dict[TwitterClient.JSONResponseKeys.CreatedAt]?.string {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = TwitterClient.Constants.DateFormat
                        if let timestampObj = dateFormatter.dateFromString(timestampStr) {
                            timestamp = timestampObj
                        }
                    }
                    category = TwitterClient.Constants.Category
                    if let user = dict[TwitterClient.JSONResponseKeys.User]?.object as [String : SwifteriOS.JSONValue]? {
                        if let locationStr = user[TwitterClient.JSONResponseKeys.Location]?.string as String? {
                            location = locationStr
                        }
                        if let timezone = user[TwitterClient.JSONResponseKeys.TimeZone]?.string as String? {
                            location = timezone
                        }
                    }
                }
                if location != StringUtil.EmptyString {
                    // check whether event already exists and if not create event
                    autoreleasepool{
                        var event : Event? = nil
                        privateContext!.performBlockAndWait {
                        event = EventRepository.getEventById(self.privateContext!, id: id)
                        if event == nil {
                            if self.clientConfig.twitterConfig.keywords.count == 0 || StringUtil.containsAtleastOneKeyword(summary, keywords: self.clientConfig.twitterConfig.keywords) {
                                event = EventRepository.createEvent(self.privateContext!, id: id, title: title, summary: summary, location: location, latitude: Double.NaN, longitude: Double.NaN, weight: 1.0, timestamp: timestamp, category: EventRepository.getCategoryById(self.privateContext!, id: MapCategory.TwitterCategoryId)!, dataSource: EventRepository.getDataSourceById(self.privateContext!, id: DataSource.TwitterDataSourceId)!)
                            }
                        }
                    }
                    if event != nil {
                        self.incrementCounter()
                    }
                    // commit after NumberOfMessageInBatch message to reduce the memory foot print and have a better performance
                    if counter % NumberOfMessageInBatch == 0 {
                        privateContext!.performBlockAndWait {
                                do {
                                    try self.privateContext!.save()
                                    self.privateContext!.reset()
                                }
                                catch {
                                    LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating twitter messages: \(error)")
                                }
                        }
                    }
                }
                }
            }
            var sinceId : String? = nil
            if let dict = searchMetadata as [String : SwifteriOS.JSONValue]? {
                sinceId = dict[TwitterClient.JSONResponseKeys.MaxIdStr]!.string
            }
            // if MaxCount message limit not reached then  
            if sinceId != nil && statuses.count>0 && self.counter < self.MaxCount{
                swifter.getSearchTweetsWithQuery(TwitterClient.URLKeys.SearchCriteria, geocode: nil, lang: nil, locale: nil, resultType:nil, count: MaxPerInvocation, until: nil, sinceID: nil, maxID: nil, includeEntities: true, callback: nil,
                    success: { (statuses, searchMetadata) -> Void in
                        self.continueOrComplete(statuses, searchMetadata: searchMetadata, completionHandler: completionHandler)
                    },
                    failure: {
                        error in
                        LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "\(error)")
                })
            }
            else {
                completionHandler(error: nil)
            }
        }
    }
}