//
//  MapLocation
//  Visivent
//
//  Created by OLIVER HAGER on 9/30/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import MapKit

/// map location (annotations used for events and points of interest)
class MapLocation: NSObject, MKAnnotation {
    /// title in right accessory view
    var title: String?
    /// subtitle (details text) of right accessory view
    var subtitle: String?
    /// location name (part of callout view title)
    var locationName: String
    /// coordinate (latitude/longitude of annotation)
    var coordinate: CLLocationCoordinate2D
    /// media URL (used for image callout view)
    var mediaURL: String
    /// secondary media URL used for Webcam in POI
    var secondaryMediaURL: String
    /// category of map location
    var category: String
    
    /// initializes attributes
    init(title: String, subtitle: String, locationName: String, category: String, mediaURL: String, secondaryMediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.locationName = locationName
        self.category = category
        self.mediaURL = mediaURL
        self.secondaryMediaURL = secondaryMediaURL
        self.coordinate = coordinate
        
        super.init()
    }
    
    /// get PIN color based on the category
    func getColor() -> UIColor {
        if category == "earthquake" {
            return UIColor.blackColor()
        }
        else if category == "volcano" {
            return UIColor.redColor()
        }
        else if category == "tweet" {
            return UIColor.greenColor()
        }
        else if category == "volcano_location" {
            return UIColor.orangeColor()
        }
        else {
            return UIColor.blueColor()
        }
    }
}