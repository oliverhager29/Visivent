//
//  MapCategory.swift
//  Visivent
//
//  Created by OLIVER HAGER on 2/10/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//
import Foundation
import CoreData
/// Category
@objc class MapCategory : NSManagedObject {
    /// name of Twitter category
    static let TwitterCategoryName = "tweet"
    /// id of Twitter category
    static let TwitterCategoryId = 1
    /// customized icon file name for Twitter category
    static let TwitterCustomizedIconFileName = ""
    /// standard pin color for Twitter category
    static let TwitterStandardPinColor = "green"
    
    /// name of news category
    static let NewsCategoryName = "news"
    /// id of news category
    static let NewsCategoryId = 2
    /// customized icon file name for news category
    static let NewsCustomizedIconFileName = ""
    /// standard pin color for news category
    static let NewsStandardPinColor = "blue"
    
    /// name of earthquake category
    static let EarthquakeCategoryName = "earthquake"
    /// id of earthquake category
    static let EarthquakeCategoryId = 3
    /// customized icon file name for earthquake category
    static let EarthquakeCustomizedIconFileName = ""
    /// standard pin color for earthquake category
    static let EarthquakeStandardPinColor = "black"
    
    /// name of volcanic activity category
    static let VolcanicActivityCategoryName = "volcano"
    /// id of volcanic activity category
    static let VolcanicActivityCategoryId = 4
    /// customized icon file name for volcanic activity category
    static let VolcanicActivityCustomizedIconFileName = ""
    /// standard pin color for volcanic activity category
    static let VolcanicActivityStandardPinColor = "red"
    
    /// name of volcano location category
    static let VolcanoLocationCategoryName = "volcano_location"
    /// id of volcano location category
    static let VolcanoLocationCategoryId = 5
    /// customized icon file name for volcano location category
    static let VolcanoLocationCustomizedIconFileName = "volcano_pin.png"
    /// standard pin color for volcano location category
    static let VolcanoLocationStandardPinColor = ""
    
    /// name of earthquake category 0
    static let EarthquakeCategory0Name = "earthquake0"
    /// id of earthquake category 0
    static let EarthquakeCategory0Id = 6
    /// customized icon file name for earthquake category 0
    static let EarthquakeCategory0CustomizedIconFileName = "earthquake0_pin.png"
    /// standard pin color for earthquake category 0
    static let EarthquakeCategory0StandardPinColor = ""
    
    /// name of earthquake category 1
    static let EarthquakeCategory1Name = "earthquake1"
    /// id of earthquake category 1
    static let EarthquakeCategory1Id = 7
    /// customized icon file name for earthquake category 1
    static let EarthquakeCategory1CustomizedIconFileName = "earthquake1_pin.png"
    /// standard pin color for earthquake category 1
    static let EarthquakeCategory1StandardPinColor = ""
    
    /// name of earthquake category 2
    static let EarthquakeCategory2Name = "earthquake2"
    /// id of earthquake category 2
    static let EarthquakeCategory2Id = 8
    /// customized icon file name for earthquake category 2
    static let EarthquakeCategory2CustomizedIconFileName = "earthquake2_pin.png"
    /// standard pin color for earthquake category 2
    static let EarthquakeCategory2StandardPinColor = ""
    
    /// name of earthquake category 3
    static let EarthquakeCategory3Name = "earthquake3"
    /// id of earthquake category 3
    static let EarthquakeCategory3Id = 9
    /// customized icon file name for earthquake category 3
    static let EarthquakeCategory3CustomizedIconFileName = "earthquake3_pin.png"
    /// standard pin color for earthquake category 3
    static let EarthquakeCategory3StandardPinColor = ""
    
    /// name of earthquake category 4
    static let EarthquakeCategory4Name = "earthquake4"
    /// id of earthquake category 4
    static let EarthquakeCategory4Id = 10
    /// customized icon file name for earthquake category 4
    static let EarthquakeCategory4CustomizedIconFileName = "earthquake4_pin.png"
    /// standard pin color for earthquake category 4
    static let EarthquakeCategory4StandardPinColor = ""
    
    /// name of earthquake category 5
    static let EarthquakeCategory5Name = "earthquake5"
    /// id of earthquake category 5
    static let EarthquakeCategory5Id = 11
    /// customized icon file name for earthquake category 5
    static let EarthquakeCategory5CustomizedIconFileName = "earthquake5_pin.png"
    /// standard pin color for earthquake category 5
    static let EarthquakeCategory5StandardPinColor=""
    
    /// name of earthquake category 6
    static let EarthquakeCategory6Name = "earthquake6"
    /// id of earthquake category 6
    static let EarthquakeCategory6Id = 12
    /// customized icon file name for earthquake category 6
    static let EarthquakeCategory6CustomizedIconFileName = "earthquake6_pin.png"
    /// standard pin color for earthquake category 6
    static let EarthquakeCategory6StandardPinColor=""
    
    /// name of earthquake category 7
    static let EarthquakeCategory7Name = "earthquake7"
    /// id of earthquake category 7
    static let EarthquakeCategory7Id = 13
    /// customized icon file name for earthquake category 7
    static let EarthquakeCategory7CustomizedIconFileName = "earthquake7_pin.png"
    /// standard pin color for earthquake category 7
    static let EarthquakeCategory7StandardPinColor=""
    
    /// name of earthquake category 8
    static let EarthquakeCategory8Name = "earthquake8"
    /// id of earthquake category 8
    static let EarthquakeCategory8Id = 14
    /// customized icon file name for earthquake category 8
    static let EarthquakeCategory8CustomizedIconFileName = "earthquake8_pin.png"
    /// standard pin color for earthquake category 8
    static let EarthquakeCategory8StandardPinColor=""
    
    /// name of earthquake category 9
    static let EarthquakeCategory9Name = "earthquake9"
    /// id of earthquake category 9
    static let EarthquakeCategory9Id = 15
    /// customized icon file name for earthquake category 9
    static let EarthquakeCategory9CustomizedIconFileName = "earthquake9_pin.png"
    /// standard pin color for earthquake category 9
    static let EarthquakeCategory9StandardPinColor=""
    
    /// name of earthquake category 10
    static let EarthquakeCategory10Name = "earthquake10"
    /// id of earthquake category 10
    static let EarthquakeCategory10Id = 16
    /// customized icon file name for earthquake category 10
    static let EarthquakeCategory10CustomizedIconFileName = "earthquake10_pin.png"
    /// standard pin color for earthquake category 10
    static let EarthquakeCategory10StandardPinColor=""
    
    /// id of category
    @NSManaged var id : Int
    /// name of category
    @NSManaged var name : String
    /// standard pin color
    @NSManaged var standardPinColor : String
    /// customized icon file name
    @NSManaged var customizedIconFileName : String
    
    /// initialize managed object
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    /// :param: id id of category
    /// :param: name name of category
    /// :param: color color of standard pin
    /// :param: customizedIconFileName customized icon file name
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, id: Int, name: String, standardPinColor: String, customizedIconFileName: String) {
        let entity =  NSEntityDescription.entityForName("MapCategory", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.name = name
        self.standardPinColor = standardPinColor
        self.customizedIconFileName = customizedIconFileName
    }
}