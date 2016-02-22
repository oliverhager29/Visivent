//
//  LocationUtil.swift
//  Visivent
//
//  Created by OLIVER HAGER on 2/14/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// Location utility class
class LocationUtil {
    /// latitude
    var latitude: Double = 0.0
    /// longitude
    var longitude: Double = 0.0
    
    /// default constructor
    init() {
        
    }
    
    /// location (primary location)
    /// :param: location geo location string
    /// :returns: Double array of latitude and longitude
    func locate(location: String) -> [Double] {
        let callNow = toSync(primaryLocate)
        var hasError = false
        do {
            let placemarks = try callNow(location)
            if placemarks == nil || placemarks!.isEmpty {
                hasError = true
            }
            else {
                let placemark = placemarks![0]
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                return [coordinates.latitude, coordinates.longitude]
            }
        }
        catch {
            hasError = true
        }
        if(hasError) {
            let callNow = toSync(backupLocate)
            do {
                let result = try callNow(location)
                let latitude = result![MapQuestClient.JSONResponseKeys.Lat]!
                let longitude = result![MapQuestClient.JSONResponseKeys.Lng]!
                return [latitude, longitude]
            }
            catch {
                hasError = true
            }
        }
        return [0.0, 0.0]
    }
    
    /// localization (primary localization)
    /// :param: location geo location string
    /// :returns: Double array of latitude and longitude
    func primaryLocate(location: String, completionHandler: CLGeocodeCompletionHandler) {
        dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((location), completionHandler: {(placemarks, error) -> Void in
                if((error) != nil || placemarks == nil || placemarks!.count == 0){
                    completionHandler(nil, error)
                }
                else {
                    completionHandler(placemarks, error)
                }
            })
        }
    }
    
    /// localization (backup if primary localization failed)
    /// :param: location geo location string
    /// :returns: Double array of latitude and longitude
    func backupLocate(location: String, completionHandler: (result: [String: Double]?, error: NSError?) -> Void) {
        dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
            let mapQuestClient = MapQuestClient()
            mapQuestClient.getCoordinates(location, completionHandler: { (result, error) -> Void in
                dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
                if error != nil {
                    LogUtil.alert(LogUtil.INFO, title: "Info: Geo location failed", message: "Geo location failed for: \(location)")
                    completionHandler(result: nil, error: error)
                }
                else if result != nil && !result!.isEmpty{
                    completionHandler(result: result, error: error)
                }
                }
            })
        }
    }
}