//
//  LocationLoader.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/15/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData
/// loads city to coordinates mapping in order to reduce the online geo decoding request
class LocationLoader {
    /// file that contains city to coordinate mapping
    let WorldCitiesFileName = "worldcitiespop"
    /// empty string constant
    static let EmptyStr = ""
    /// country constant
    static let CountryStr = "Country"
    /// country code to name mapping
    var countryCodeToNameMap : [String:String] = [:]
    /// singleton
    static let instance = LocationLoader()
    /// db context
    let privateContext : NSManagedObjectContext!
    /// initialize db context
    init() {
        privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator =
            CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
        
    }
    
    /// load city to coordinate mapping
    func loadCityCoordinates(completionHandler : (error: ErrorType?) -> ()) {
        LogUtil.alert(LogUtil.INFO, title: "City Coordinates", message: "Started loading City Coordinates")
        let fileReader = FileReader(fileName: WorldCitiesFileName, processLine: {
            lineNumber, line in
            var row = CSVReader.parseCSVLine(line)
            if row.count >= 7 && row[0] != LocationLoader.CountryStr {
                let countryCode = row[0]
                let city = row[1]
                //let state = row[3]
                let populationStr = row[4]
                var population : Int32 = 0
                if populationStr != LocationLoader.EmptyStr {
                    if let val = Int32(populationStr) as Int32? {
                        population = val
                    }
                 }
                let latitudeStr = row[5]
                let longitudeStr = row[6]
                if countryCode != LocationLoader.EmptyStr && city != LocationLoader.EmptyStr && latitudeStr != LocationLoader.EmptyStr && longitudeStr != LocationLoader.EmptyStr {
                    if let latitude = Double(latitudeStr) as Double? {
                        if let longitude = Double(longitudeStr) as Double? {
                            self.privateContext!.performBlockAndWait {
                                EventRepository.createLocation(self.privateContext, location: city, latitude: latitude, longitude: longitude, population: population)
                                if lineNumber%10000 == 0 {
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
                    }
                }
            }
        })
        fileReader.processFile()
        self.privateContext!.performBlockAndWait {
            do {
                try self.privateContext.save()
                self.privateContext.reset()
                completionHandler(error: nil)
            }
            catch {
                completionHandler(error: error)
                LogUtil.alert(LogUtil.ERROR, title: "DB error", message: "Error creating locations: \(error)")
            }
        }
        LogUtil.alert(LogUtil.INFO, title: "City Coordinates", message: "Finished loading City Coordinates")
    }

    /// get singleton instance
    /// :param: singleton instance
    static func sharedInstance() -> LocationLoader {
        return instance
    }
}