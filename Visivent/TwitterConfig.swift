//
//  TwitterConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/6/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - File Support
/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-twitter-Context")

// MARK: - RSSConfig: NSObject, NSCoding
/// MapQuest client configuration
class TwitterConfig: NSObject, NSCoding {
    
    // MARK: Properties
    /// is data collected in the database
    var isDataCollectionEnabled : Bool = true
    /// is activity displayed in the map
    var isDisplayed : Bool = true
    /// Twitter consumer key (only for demo purposes, another consumer key can be configured)
    var consumerKey : String = "WZiogG1AC9Y3zQxiAxisUJJrF"
    /// Twitter consumer secret (only demo purposes, another consumer secret can be configured)
    var consumerSecret : String = "S9vJAs94BBbaiv40NsCdVED15oIgdNsLCJg9NVG2jmPv020028"
    /// minimum hours on the slider
    var minHours : Int = 1
    /// maximum hours to keep events
    var maxHours : Int = 72
    /// messages are only collected that contains at least one keyword in keywords. If keywords is empty, then all messages are collected. 
    var keywords = NSMutableArray()
    /// interval in seconds when reading Twitter messages is repeated
    var refreshInterval = 3600
    /// seconds to wait until the first time Twitter messages are read
    var startTime = 240
    
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
        if dictionary.keys.contains(ConsumerKeyKey) {
            self.consumerKey = dictionary[ConsumerKeyKey] as! String
        }
        if dictionary.keys.contains(ConsumerSecretKey) {
            self.consumerSecret = dictionary[ConsumerSecretKey] as! String
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
    }
    
    // MARK: Update
    
    
    // MARK: NSCoding
    /// keys
    let IsDataCollectionEnabledKey =  "config.is_data_collection_enabled_key"
    let IsDisplayedKey =  "config.is_displayed_key"
    let ConsumerKeyKey = "config.consumer_key_key"
    let ConsumerSecretKey = "config.consumer_secret_key"
    let MinHoursKey = "config.min_hours_key"
    let MaxHoursKey = "config.max_hours_key"
    let KeywordsKey = "config.keywords_key"
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
        if aDecoder.containsValueForKey(ConsumerKeyKey) {
            consumerKey = aDecoder.decodeObjectForKey(ConsumerKeyKey) as! String
        }
        if aDecoder.containsValueForKey(ConsumerSecretKey) {
            consumerSecret = aDecoder.decodeObjectForKey(ConsumerSecretKey) as! String
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
    }
    
    /// serialize configuration to file
    /// :param: aCoder coder (serializer)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(isDataCollectionEnabled, forKey: IsDataCollectionEnabledKey)
        aCoder.encodeObject(isDisplayed, forKey: IsDisplayedKey)
        aCoder.encodeObject(consumerKey, forKey: ConsumerKeyKey)
        aCoder.encodeObject(consumerSecret, forKey: ConsumerSecretKey)
        aCoder.encodeObject(minHours, forKey: MinHoursKey)
        aCoder.encodeObject(maxHours, forKey: MaxHoursKey)
        aCoder.encodeObject(keywords, forKey: KeywordsKey)
        aCoder.encodeObject(refreshInterval, forKey: RefreshIntervalKey)
        aCoder.encodeObject(startTime, forKey: StartTimeKey)
    }
    
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> TwitterConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? TwitterConfig
        } else {
            return nil
        }
    }
}