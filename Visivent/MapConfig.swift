//
//  MapConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/17/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - File Support
/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-map-Context")

// MARK: - MapConfig: NSObject, NSCoding
/// map configuration
class MapConfig: NSObject, NSCoding {
    
    // MARK: Properties
    
    /// is map shown in standard view
    var isStandardMapView = true
    /// is map shown in satellite view
    var isSatelliteMapView = false
    /// are Pins shown
    var isPinShown = true
    /// is a heat map overlay shown
    var isHeatShown = false
    /// maximum hours on the slider
    var maxHours = 72
    /// size of sliding window (in animation mode)
    var slidingTimeWindow = 4
    
    // MARK: Initialization
    /// default constructor
    override init() {}
    /// initialize from dictionary
    /// :param: dictionary configuration key-value pairs
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        if dictionary.keys.contains(IsStandardMapViewKey) {
            self.isStandardMapView = dictionary[IsStandardMapViewKey] as! Bool
        }
        if dictionary.keys.contains(IsSatelliteMapViewKey) {
            self.isSatelliteMapView = dictionary[IsStandardMapViewKey] as! Bool
        }
        if dictionary.keys.contains(IsPinShownKey) {
            self.isPinShown = dictionary[IsPinShownKey] as! Bool
        }
        if dictionary.keys.contains(IsHeatShownKey) {
            self.isHeatShown = dictionary[IsHeatShownKey] as! Bool
        }
        if dictionary.keys.contains(MaxHoursKey) {
            self.maxHours = dictionary[MaxHoursKey] as! Int
        }
        if dictionary.keys.contains(SlidingTimeWindowKey) {
            self.slidingTimeWindow = dictionary[SlidingTimeWindowKey] as! Int
        }
    }

    // MARK: NSCoding
    /// keys
    let IsStandardMapViewKey =  "config.is_standard_map_view_key"
    let IsSatelliteMapViewKey =  "config.is_satellite_map_view_key"
    let IsPinShownKey =  "config.is_pin_shown_key"
    let IsHeatShownKey =  "config.is_heat_shown_key"
    let MaxHoursKey = "config.max_hours_key"
    let SlidingTimeWindowKey = "config.sliding_time_window_key"
    /// initialize by decoding serialized configuration file
    /// :param: aDecoder decoder (deserializer)
    required init(coder aDecoder: NSCoder) {
        isStandardMapView = aDecoder.decodeObjectForKey(IsStandardMapViewKey) as! Bool
        isSatelliteMapView = aDecoder.decodeObjectForKey(IsSatelliteMapViewKey) as! Bool
        isPinShown = aDecoder.decodeObjectForKey(IsPinShownKey) as! Bool
        isHeatShown = aDecoder.decodeObjectForKey(IsHeatShownKey) as! Bool
        maxHours = aDecoder.decodeObjectForKey(MaxHoursKey) as! Int
        slidingTimeWindow =  aDecoder.decodeObjectForKey(SlidingTimeWindowKey) as! Int
    }
    /// serialize configuration to file
    /// :param: aCoder coder (serializer)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(isStandardMapView, forKey: IsStandardMapViewKey)
        aCoder.encodeObject(isSatelliteMapView, forKey: IsSatelliteMapViewKey)
        aCoder.encodeObject(isPinShown, forKey: IsPinShownKey)
        aCoder.encodeObject(isHeatShown, forKey: IsHeatShownKey)
        aCoder.encodeObject(maxHours, forKey: MaxHoursKey)
        aCoder.encodeObject(slidingTimeWindow, forKey: SlidingTimeWindowKey)
    }
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> MapConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? MapConfig
        } else {
            return nil
        }
    }
}
