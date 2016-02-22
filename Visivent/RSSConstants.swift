//
//  RSSConstants.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/16/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

extension RSSClient {
    struct Constants {
        /// base URL
        static let BaseUrl = "http://feeds.reuters.com/"
        /// mapping news topics to sub URL
        static let TopicsToURL = [
            "Arts" : "news/artsculture",
            "Business" : "reuters/businessNews",
            "Company News"	: "reuters/companyNews",
            "Entertainment" : "reuters/entertainment",
            "Environment" : "reuters/environment",
            "Health News"	: "reuters/healthNews",
            "Lifestyle" :	"reuters/lifestyle",
            "Media" : "news/reutersmedia",
            "Money" : "news/wealth",
            "Most Read Articles" : "reuters/MostRead",
            "Oddly Enough" : "reuters/oddlyEnoughNews",
            "People" : "reuters/peopleNews",
            "Politics" : "Reuters/PoliticsNews",
            "Science" : "reuters/scienceNews",
            "Sports" : "reuters/sportsNews",
            "Technology" : "reuters/technologyNews",
            "Top News" : "reuters/topNews",
            "US News" : "Reuters/domesticNews",
            "World" : "Reuters/worldNews"]
        
        /// news topics
        static let Topics = [
            "Arts",
            "Business",
            "Company News",
            "Entertainment",
            "Environment",
            "Health News",
            "Lifestyle",
            "Media",
            "Money",
            "Most Read Articles",
            "Oddly Enough",
            "People",
            "Politics",
            "Science",
            "Sports",
            "Technology",
            "Top News",
            "US News",
            "World"]
    }
    /// parameter keys
    struct ParameterKeys {
        static let Format = "format"
    }
    /// parameter constants
    struct ParameterConstants {
        static let XML = "XML"
    }
    /// XML response keys
    struct XMLResponseKeys {
        static let Item = "item"
        static let Description = "description"
        static let PubDate = "pubDate"
        static let Category = "category"
        static let GUID = "guid"
        static let Title = "title"
        static let Type = "type"
        static let Time = "time"
        static let Timezone = "tz"
        static let Tsunami = "tsunami"
        static let Magnitude = "mag"
    }
}