//
//  USGSConfig.swift
//  Visivent
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import Foundation

// MARK: - File Support
/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to serialized configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-usgs-Context")

// MARK: - USGSConfig: NSObject, NSCoding
/// configuration for the USGS client for getting earthquake data
class USGSConfig: NSObject, NSCoding {
    
    // MARK: Properties
    /// is data collected in the database
    var isDataCollectionEnabled : Bool = false
    /// is activity displayed in the map
    var isDisplayed : Bool = true
    /// minimum hours on the slider
    var minHours : Int = 1
    /// maximum hours to keep events
    var maxHours : Int = 72
    /// only earthquakes with at least minMagnitude magnitude are collected
    var minMagnitude : Double = 0.0
    /// refresh interval in seconds for reading volcanic activity events
    var refreshInterval = 3600
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
        if dictionary.keys.contains(IsDisplayedKey) {
            self.isDisplayed = dictionary[IsDisplayedKey] as! Bool
        }
        if dictionary.keys.contains(MinHoursKey) {
            self.minHours = dictionary[MinHoursKey] as! Int
        }
        if dictionary.keys.contains(MaxHoursKey) {
            self.maxHours = dictionary[MaxHoursKey] as! Int
        }
        if dictionary.keys.contains(MinMagnitudeKey) {
            self.minMagnitude = dictionary[MinMagnitudeKey] as! Double
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
    let IsDisplayedKey =  "config.is_displayed_key"
    let MinHoursKey = "config.min_hours_key"
    let MaxHoursKey = "config.max_hours_key"
    let MinMagnitudeKey = "config.min_magnitude_key"
    let RefreshIntervalKey = "config.refresh_interval_key"
    let StartTimeKey = "config.start_time_key"
    /// initialize by decoding serialized configuration file
    /// :param: aDecoder decoder (deserializer)
    required init(coder aDecoder: NSCoder) {
        if aDecoder.containsValueForKey(IsDataCollectionEnabledKey) {
            isDataCollectionEnabled = aDecoder.decodeObjectForKey(IsDataCollectionEnabledKey) as! Bool
        }
        if aDecoder.containsValueForKey(IsDisplayedKey) {
            isDisplayed = aDecoder.decodeObjectForKey(IsDisplayedKey) as! Bool
        }
        if aDecoder.containsValueForKey(MinHoursKey) {
            minHours = aDecoder.decodeObjectForKey(MinHoursKey) as! Int
        }
        if aDecoder.containsValueForKey(MaxHoursKey) {
            maxHours = aDecoder.decodeObjectForKey(MaxHoursKey) as! Int
        }
        if aDecoder.containsValueForKey(MinMagnitudeKey) {
            minMagnitude = aDecoder.decodeObjectForKey(MinMagnitudeKey) as! Double
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
        aCoder.encodeObject(isDisplayed, forKey: IsDisplayedKey)
        aCoder.encodeObject(minHours, forKey: MinHoursKey)
        aCoder.encodeObject(maxHours, forKey: MaxHoursKey)
        aCoder.encodeObject(minMagnitude, forKey: MinMagnitudeKey)
        aCoder.encodeObject(refreshInterval, forKey: RefreshIntervalKey)
        aCoder.encodeObject(startTime, forKey: StartTimeKey)
    }
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> USGSConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? USGSConfig
        } else {
            return nil
        }
    }
}
