//
//  MapQuestConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/29/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - File Support
/// path to documents directory
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
/// path to configuration file
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("visivent-mapquest-Context")

// MARK: - MapQuestConfig: NSObject, NSCoding
/// MapQuest client configuration
class MapQuestConfig: NSObject, NSCoding {
    
    // MARK: Properties
    
   /// default API key (for demo purposes only)
   var apiKey = "mrFN5KbqXSTrKzMIGaqlUbGGA1nZaqjE"

    // MARK: Initialization
    
    override init() {}
    /// initialize configuration by dictionary
    /// :param: dictionary configuration key-value pairs
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        if dictionary.keys.contains(ApiKeyKey) {
            self.apiKey = dictionary[ApiKeyKey] as! String
        }
    }
    
    // MARK: NSCoding
    ///API key
    let ApiKeyKey =  "config.api_key_key"
    
    /// initialize by decoding serialized configuration file
    /// :param: aDecoder decoder (deserializer)
    required init(coder aDecoder: NSCoder) {
        if aDecoder.containsValueForKey(ApiKeyKey) {
            apiKey = aDecoder.decodeObjectForKey(ApiKeyKey) as! String
        }
    }
    
    /// serialize configuration to file
    /// :param: aCoder coder (serializer)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(apiKey, forKey: ApiKeyKey)
    }
    
    /// save to serialize data to file
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    /// read serialized configuration from file
    /// :returns: configuration object
    class func unarchivedInstance() -> MapQuestConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? MapQuestConfig
        } else {
            return nil
        }
    }
}
