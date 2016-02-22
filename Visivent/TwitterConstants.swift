//
//  TwitterConstants.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/22/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

// MARK: - TwitterClient (Constants)

extension TwitterClient {
    
    // MARK: Constants
    struct Constants {
        static let DoubleQuote = "\""
        static let DateFormat = "EEE, MMM dd HH:mm:ss +zzzz yyyy"
        // MARK: URLs
        static let RestBaseURLSecure : String = "https://api.twitter.com/1.1/"
        static let RestCredentialsURLSecure = RestBaseURLSecure + "account/verify_credentials.json"
        static let RestUserTimelineURLSecure = RestBaseURLSecure + "statuses/user_timeline.json"
        static let Category = "tweet"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let SearchCriteria = "%40twitterapi"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Text = "text"
        static let IdStr = "id_str"
        static let CreatedAt = "created_at"
        static let User = "user"
        static let Location = "location"
        static let TimeZone = "time_zone"
        static let MaxIdStr = "max_id_str"
    }
    
}