//
//  GVPConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/25/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - File Support

/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to serialized configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-gvp-Context")

// MARK: - GVPConfig: NSObject, NSCoding
/// configuration for the GVP client for getting volcanic activity events and volcanic points of interest
class GVPConfig: NSObject, NSCoding {
    
    // MARK: Properties
    /// is data collected in the database
    var isDataCollectionEnabled : Bool = true
    /// is activity displayed in the map
    var isActivityDisplayed : Bool = true
    /// is volcano location displayed in the map
    var isLocationDisplayed : Bool = true
    /// minimum hours on the slider
    var minHours : Int = 1
    /// maximum hours to keep events
    var maxHours : Int = 2880
    /// refresh interval in seconds for reading volcanic activity events
    var refreshInterval = 10080
    /// time in seconds when the volcanic events are read for the first time
    var startTime = 0
    
    // MARK: Initialization
    /// default constructor
    override init() {}
    /// initialize from dictionary
    /// :param: dictionary configuration key-value pairs
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        if dictionary.keys.contains(IsDataCollectionEnabledKey) {
            self.isDataCollectionEnabled = dictionary[IsDataCollectionEnabledKey] as! Bool
        }
        if dictionary.keys.contains(IsActivityDisplayedKey) {
            self.isActivityDisplayed = dictionary[IsActivityDisplayedKey] as! Bool
        }
        if dictionary.keys.contains(IsLocationDisplayedKey) {
            self.isLocationDisplayed = dictionary[IsLocationDisplayedKey] as! Bool
        }
        if dictionary.keys.contains(MinHoursKey) {
            self.minHours = dictionary[MinHoursKey] as! Int
        }
        if dictionary.keys.contains(MaxHoursKey) {
            self.maxHours = dictionary[MaxHoursKey] as! Int
        }
        if dictionary.keys.contains(RefreshIntervalKey) {
            self.refreshInterval = dictionary[RefreshIntervalKey] as! Int
        }
        if dictionary.keys.contains(StartTimeKey) {
            self.startTime = dictionary[StartTimeKey] as! Int
        }
    }
    
    // MARK: NSCoding
    /// keys
    let IsDataCollectionEnabledKey =  "config.is_data_collection_enabled_key"
    let IsActivityDisplayedKey =  "config.is_activity_displayed_key"
    let IsLocationDisplayedKey =  "config.is_location_displayed_key"
    let MinHoursKey = "config.min_hours_key"
    let MaxHoursKey = "config.max_hours_key"
    let RefreshIntervalKey = "config.refresh_interval_key"
    let StartTimeKey = "config.start_time_key"
    
    /// initialize by decoding serialized configuration file
    /// :param: aDecoder decoder (deserializer)
    required init(coder aDecoder: NSCoder) {
        if aDecoder.containsValueForKey(IsDataCollectionEnabledKey) {
            isDataCollectionEnabled = aDecoder.decodeObjectForKey(IsDataCollectionEnabledKey) as! Bool
        }
        if aDecoder.containsValueForKey(IsActivityDisplayedKey) {
            isActivityDisplayed = aDecoder.decodeObjectForKey(IsActivityDisplayedKey) as! Bool
        }
        if aDecoder.containsValueForKey(IsLocationDisplayedKey) {
            isLocationDisplayed = aDecoder.decodeObjectForKey(IsLocationDisplayedKey) as! Bool
        }
        if aDecoder.containsValueForKey(MinHoursKey) {
            minHours = aDecoder.decodeObjectForKey(MinHoursKey) as! Int
        }
        if aDecoder.containsValueForKey(MaxHoursKey) {
            maxHours = aDecoder.decodeObjectForKey(MaxHoursKey) as! Int
        }
        if aDecoder.containsValueForKey(RefreshIntervalKey) {
            refreshInterval = aDecoder.decodeObjectForKey(RefreshIntervalKey) as! Int
        }
        if aDecoder.containsValueForKey(StartTimeKey) {
            startTime = aDecoder.decodeObjectForKey(StartTimeKey) as! Int
        }
    }
    
    /// serialize configuration to file
    /// :param: aCoder coder (serializer)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(isDataCollectionEnabled, forKey: IsDataCollectionEnabledKey)
        aCoder.encodeObject(isActivityDisplayed, forKey: IsActivityDisplayedKey)
        aCoder.encodeObject(isLocationDisplayed, forKey: IsLocationDisplayedKey)
        aCoder.encodeObject(minHours, forKey: MinHoursKey)
        aCoder.encodeObject(maxHours, forKey: MaxHoursKey)
        aCoder.encodeObject(refreshInterval, forKey: RefreshIntervalKey)
        aCoder.encodeObject(startTime, forKey: StartTimeKey)
    }
    
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> GVPConfig? {
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? GVPConfig
        } else {
            return nil
        }
    }
}
