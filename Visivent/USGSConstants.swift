//
//  USGSConstants.swift
//  Visivent
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

// MARK: - USGSClient (Constants)

extension USGSClient {
    
    // MARK: Constants
    struct Constants {
        
        
        // MARK: URLs
        // http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson
        // http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson
        // http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson
        static let RestBaseURLSecure : String = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/{period}.geojson"
    }
    
    // MARK: Methods
    /// period over which earthquake events are returned
    struct Periods {
        static let allHour = "all_hour"
        static let allDay = "all_day"
        static let allWeek = "all_week"
    }

    // MARK: URL Keys
    struct URLKeys {
        static let Period = "period"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Features = "features"
        static let Geometry = "geometry"
        static let Coordinates = "coordinates"
        static let Id = "id"
        static let Properties = "properties"
        static let Title = "title"
        static let Type = "type"
        static let Time = "time"
        static let Timezone = "tz"
        static let Tsunami = "tsunami"
        static let Magnitude = "mag"
    }
}