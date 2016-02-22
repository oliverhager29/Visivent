//
//  MapQuestConstants.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/29/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - MapQuestClient (Constants)

extension MapQuestClient {
    
    // MARK: Constants
    struct Constants {
        /// parameterized URL
        static let RestBaseURLSecure : String = "http://www.mapquestapi.com/geocoding/v1/address?key={apiKey}&location={location}"
    }
    
    /// URL keys
    struct URLKeys {
        static let ApiKey = "apiKey"
        static let Location = "location"
    }
    
    /// JSON Response Keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let Locations = "locations"
        static let DisplayLatLng = "displayLatLng"
        static let Lat = "lat"
        static let Lng = "lng"
        static let Info = "info"
        static let Messages = "messages"
        static let StatusCode = "statuscode"
    }
}