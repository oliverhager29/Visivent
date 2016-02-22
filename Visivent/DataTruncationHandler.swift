//
//  DataTruncationHandler.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/23/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData
/// Schedules data truncation
class DataTruncationHandler {
    static var sharedInstance: DataTruncationHandler {
        return DataTruncationHandler()
    }
    /// client configuration
    var clientConfig : ClientConfig!
    /// initialize client configuration and initiate first data truncation
    init() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        // start after a minute (to distribute the workload)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(60),
            target: self, selector: "truncateEvents", userInfo: nil, repeats: false)
    }
    
    /// truncate events and schedule next truncation
    @objc func truncateEvents() {
        LogUtil.alert(LogUtil.INFO, title: "Truncation", message: "Start deleting old events")
        let privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator =
            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
        privateContext.performBlockAndWait {
            EventRepository.truncateData(privateContext, dataSourceId: DataSource.ReutersDataSourceId, maxHours: self.clientConfig.rssConfig.maxHours)
            EventRepository.truncateData(privateContext, dataSourceId: DataSource.USGSDataSourceId, maxHours: self.clientConfig.usgsConfig.maxHours)
            EventRepository.truncateData(privateContext, dataSourceId: DataSource.GVPDataSourceId, maxHours: self.clientConfig.gvpConfig.maxHours)
            EventRepository.truncateData(privateContext, dataSourceId: DataSource.TwitterDataSourceId, maxHours: self.clientConfig.twitterConfig.maxHours)
            do {
                try privateContext.save()
                privateContext.reset()
            }
            catch {
                LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Deleting old events")
            }
        }
        //repeat every hour
        NSTimer.scheduledTimerWithTimeInterval(60*60,
        target: self, selector: "truncateEvents", userInfo: nil, repeats: true)
        LogUtil.alert(LogUtil.INFO, title: "Truncation", message: "Finished deleting old events")
    }
}