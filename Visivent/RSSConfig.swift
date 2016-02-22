//
//  RSSConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/16/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - File Support
/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to serialized configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-rss-Context")

// MARK: - RSSConfig: NSObject, NSCoding
/// configuration for the Reuters client for getting news data
class RSSConfig: NSObject, NSCoding {
    
    // MARK: Properties
    /// is data collected in the database
    var isDataCollectionEnabled : Bool = true
    /// is activity displayed in the map
    var isDisplayed : Bool = true
    /// minimum hours on the slider
    var minHours : Int = 1
    /// maximum hours on the slider
    var maxHours : Int = 72
    /// messages are only collected that contains at least one keyword in keywords. If keywords is empty, then all messages are collected.
    var keywords = NSMutableArray()
    /// interval in seconds when reading Reuters News messages is repeated
    var refreshInterval = 3600
    /// seconds to wait until the first time Reuters News messages are read
    var startTime = 0
    /// news topics to read
    var topics = NSMutableArray()
    
    // MARK: Initialization
    
    /// default constructor
    override init() {
        topics.addObjectsFromArray(RSSClient.Constants.Topics)
    }
    
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
        if dictionary.keys.contains(KeywordsKey) {
            self.keywords = dictionary[KeywordsKey] as! NSMutableArray
        }
        if dictionary.keys.contains(RefreshIntervalKey) {
            self.refreshInterval = dictionary[RefreshIntervalKey] as! Int
        }
        if dictionary.keys.contains(StartTimeKey) {
            self.startTime = dictionary[StartTimeKey] as! Int
        }
        if dictionary.keys.contains(TopicsKey) {
            self.topics = dictionary[TopicsKey] as! NSMutableArray
        }
    }
    
    // MARK: Update
    
    
    // MARK: NSCoding
    /// keys
    let IsDataCollectionEnabledKey =  "config.is_data_collection_enabled_key"
    let IsDisplayedKey =  "config.is_displayed_key"
    let MinHoursKey = "config.min_hours_key"
    let MaxHoursKey = "config.max_hours_key"
    let KeywordsKey = "config.keywords_key"
    let RefreshIntervalKey = "config.refresh_interval_key"
    let StartTimeKey = "config.start_time_key"
    let TopicsKey = "config.topics_key"
    
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
        if aDecoder.containsValueForKey(KeywordsKey) {
            keywords = aDecoder.decodeObjectForKey(KeywordsKey) as! NSMutableArray
        }
        if aDecoder.containsValueForKey(RefreshIntervalKey) {
            refreshInterval = aDecoder.decodeObjectForKey(RefreshIntervalKey) as! Int
        }
        if aDecoder.containsValueForKey(StartTimeKey) {
            startTime = aDecoder.decodeObjectForKey(StartTimeKey) as! Int
        }
        if aDecoder.containsValueForKey(TopicsKey) {
            topics = aDecoder.decodeObjectForKey(TopicsKey) as! NSMutableArray
        }
    }
    /// serialize configuration to file
    /// :param: aCoder coder (serializer)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(isDataCollectionEnabled, forKey: IsDataCollectionEnabledKey)
        aCoder.encodeObject(isDisplayed, forKey: IsDisplayedKey)
        aCoder.encodeObject(minHours, forKey: MinHoursKey)
        aCoder.encodeObject(maxHours, forKey: MaxHoursKey)
        aCoder.encodeObject(keywords, forKey: KeywordsKey)
        aCoder.encodeObject(refreshInterval, forKey: RefreshIntervalKey)
        aCoder.encodeObject(startTime, forKey: StartTimeKey)
        aCoder.encodeObject(topics, forKey: TopicsKey)
    }
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> RSSConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? RSSConfig
        } else {
            return nil
        }
    }
}
