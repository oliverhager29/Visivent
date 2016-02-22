//
//  VolcanoLoader.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/29/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// Loads volcano locations from a text file
class VolcanoLoader {
    /// text file name
    let VolcanoFileName = "volcano_list"
    /// db context
    let privateContext : NSManagedObjectContext!

    /// initialize db context and schedule one-time load of volcanoes (load checks for existing locations and add new locations if they do not exist in the db)
    init() {
        privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator =
            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
        EventRepository.sharedInstance
    }
    
    /// load volcano location from the text file into the db
    func loadVolcanoes(completionHandler: () -> ()) {
        LogUtil.alert(LogUtil.INFO, title: "Volcano Locations", message: "Started loading Volcano Locations")
        let fileReader = FileReader(fileName: VolcanoFileName, processLine: {
            lineNumber, line in
            if let data = line.dataUsingEncoding(NSISOLatin1StringEncoding) as NSData? {
                let str = NSString(data: data, encoding: NSISOLatin1StringEncoding) as! String
                self.extractAndPersistVolcanoData(lineNumber, line: str)
                //only commit every 100th row to save memory
                if lineNumber%100 == 0 {
                    self.privateContext!.performBlockAndWait {
                        do {
                            try self.privateContext.save()
                            self.privateContext.reset()
                        }
                        catch {
                            LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating locations: \(error)")
                        }
                    }
                }
            }
            
        })
        fileReader.processFile()
        /// final commit (of not yet committed rows)
        self.privateContext!.performBlockAndWait {
            do {
                try self.privateContext.save()
                self.privateContext.reset()
            }
            catch {
                LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating locations: \(error)")
            }
        }
        LogUtil.alert(LogUtil.INFO, title: "Volcano Locations", message: "Finished loading Volcano Locations")
        completionHandler()
    }
    
    /// extract volcano location data from line string and store in the db
    /// :param: string line string
    func extractAndPersistVolcanoData(lineNumber: Int, line: String) {
        self.privateContext!.performBlockAndWait {
        var parts : [String] = []
        let strArr=line.componentsSeparatedByString(StringUtil.DoubleQuoteString)
        for str in strArr {
            let cleanedStr = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: StringUtil.BlankString))
            if cleanedStr != StringUtil.CommaString && cleanedStr != StringUtil.EmptyString {
                parts.append(str)
            }
        }
        let category = EventRepository.getCategoryById(self.privateContext, id: MapCategory.VolcanoLocationCategoryId)!
        // location without any image and webcam link
        if parts.count == 3 {
            let coordinatesStrArr = parts[1].componentsSeparatedByString(StringUtil.CommaString)
            if let longitude = Double(coordinatesStrArr[0]) as Double? {
                if let latitude = Double(coordinatesStrArr[1]) as Double? {
                    self.privateContext!.performBlockAndWait {
                        if PointOfInterestRepository.getPointOfInterestByName(self.privateContext, name: parts[0]) == nil {
                            PointOfInterestRepository.createPointOfInterest(self.privateContext, name: parts[0], latitude: latitude, longitude: longitude, imageUrl: StringUtil.EmptyString, webcamUrl: StringUtil.EmptyString, summary: parts[2], category: category)
                        }
                    }
                }
            }
        }
        // location only with image link
        else if parts.count == 4 {
            let coordinatesStrArr = parts[1].componentsSeparatedByString(StringUtil.CommaString)
            if let longitude = Double(coordinatesStrArr[0]) as Double? {
                if let latitude = Double(coordinatesStrArr[1]) as Double? {
                    self.privateContext!.performBlockAndWait {
                        if PointOfInterestRepository.getPointOfInterestByName(self.privateContext, name: parts[0]) == nil {
                            PointOfInterestRepository.createPointOfInterest(self.privateContext, name: parts[0], latitude: latitude, longitude: longitude, imageUrl: parts[2], webcamUrl: StringUtil.EmptyString, summary: parts[3], category: category)
                        }
                    }
                }
            }
        }
        // location with image and webcam link
        else if parts.count == 5 {
            let coordinatesStrArr = parts[1].componentsSeparatedByString(StringUtil.CommaString)
            if let longitude = Double(coordinatesStrArr[0]) as Double? {
                if let latitude = Double(coordinatesStrArr[1]) as Double? {
                    self.privateContext!.performBlockAndWait {
                        if PointOfInterestRepository.getPointOfInterestByName(self.privateContext, name: parts[0]) == nil {
                            PointOfInterestRepository.createPointOfInterest(self.privateContext, name: parts[0], latitude: latitude, longitude: longitude, imageUrl: parts[2], webcamUrl: parts[3], summary: parts[4], category: category)
                        }
                    }
                }
            }
        }
        // incomplete data
        else {
            LogUtil.alert(LogUtil.ERROR, title: "File error", message: "Error: wrong format in line:\(lineNumber)")
        }
        }
    }
}