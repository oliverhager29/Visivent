//
//  LogUtil.swift
//  Visivent
//
//  Created by OLIVER HAGER on 2/10/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// Log utility class for writing log entries and sending notifications to the notification center and the UIViewController for opening an alert
class LogUtil {
    /// error severity
    static let ERROR = "ERROR"
    /// info severity
    static let INFO = "INFO"
    
    /// error notification category
    static let ERROR_CATEGORY = "ERROR_CATEGORY"
    /// info notification category
    static let INFO_CATEGORY = "INFO_CATEGORY"
    
    /// time interval during which duplicate error/info messages are elimintaed
    static let DuplicateTimeInterval = 10
    /// map for reducing too many duplicate error/info messages with in DuplicateTimeInterval seconds
    static var alertMap : [String : NSDate] = [:]
    
    /// alert a message (error/info)
    /// :param: severity error/info
    /// :param: title title (alert/notification title)
    /// :param: message message (alert/notification body)
    static func alert(severity: String, title: String, message: String) {
        let date : NSDate? = alertMap["\(title): \(message)"]
        if date == nil || date!.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            alertMap["\(title): \(message)"] = NSDate().dateByAddingTimeInterval(NSTimeInterval(DuplicateTimeInterval))
            NSLog("\(title): \(message)")
            let notification = UILocalNotification()
            notification.alertBody = message
            notification.alertTitle = title
            notification.alertAction = "open"
            notification.fireDate = NSDate()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["UUID": NSUUID().UUIDString]
            notification.category = severity+"_CATEGORY"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            let notificationCenter = NSNotificationCenter.defaultCenter()
            let directNotification = NSNotification(name: notification.category!, object: notification.alertBody)
            notificationCenter.postNotification(directNotification)
        }
    }
    
    static func initNotificationSettings() {
        let errorAction = UIMutableUserNotificationAction()
        errorAction.identifier = "ERROR_ACTION"
        errorAction.title = "Error"
        errorAction.activationMode = UIUserNotificationActivationMode.Foreground
        errorAction.authenticationRequired = true
        errorAction.destructive = false
        let errorCategory = UIMutableUserNotificationCategory()
        errorCategory.identifier = "ERROR_CATEGORY"
        errorCategory.setActions([errorAction],
            forContext: UIUserNotificationActionContext.Default)
        
        let infoAction = UIMutableUserNotificationAction()
        infoAction.identifier = "INFO_ACTION"
        infoAction.title = "Info"
        infoAction.activationMode = UIUserNotificationActivationMode.Foreground
        infoAction.authenticationRequired = true
        infoAction.destructive = false
        let infoCategory = UIMutableUserNotificationCategory()
        infoCategory.identifier = "INFO_CATEGORY"
        infoCategory.setActions([infoAction],
            forContext: UIUserNotificationActionContext.Default)
        
        let types = UIUserNotificationType.Alert.union(UIUserNotificationType.Sound)
        let categories = Set([errorCategory, infoCategory])
        let settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
}