//
//  GVPConstants.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/25/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

// MARK: - GVPClient (Constants)

extension GVPClient {
    
    // MARK: Constants
    struct Constants {
        // MARK: URLs
        static let RestBaseURLSecure : String = "http://volcano.si.edu/news/WeeklyVolcanoCAP.xml"
    }
    
    // MARK: XML Response Keys
    struct XMLResponseKeys {
        static let Sent = "sent"
        static let Info = "info"
        static let Headline = "headline"
        static let Description = "description"
        static let Area = "area"
        static let AreaDesc = "areaDesc"
        static let Circle = "circle"
    }
}