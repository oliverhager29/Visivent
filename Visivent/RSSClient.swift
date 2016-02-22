//
//  RSSClient.swift
//  Visivent
//
//  Created by OLIVER HAGER on 11/16/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData

class RSSClient : NSObject, NSXMLParserDelegate {
    /// session
    var session: NSURLSession
    /// data collected during parsing XML
    var isItemAvailable = false
    var isDescriptionAvailable = false
    var xmlElementStack : [String] = []
    var id = ""
    var longitude = 0.0
    var latitude = 0.0
    var title = ""
    var summary = ""
    var category = ""
    var location = ""
    var timestamp = NSDate()
    var events : [Event] = []
    
    /// client configuration
    var config : RSSConfig?
    var clientConfig : ClientConfig!
    
    /// initialize session and client configuration
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        self.config = clientConfig.rssConfig
    }
    
    // MARK: GET
    
    /// task for sending GET request to Reuters
    /// :param: topic new topic
    /// :param: parameters URL parameters
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForGETMethod(topic: String, parameters: [String : AnyObject], completionHandler: (result: [Event], error: NSError?) -> Void) -> NSURLSessionDataTask {
        /* 1. Set the parameters */
        let mutableParameters = parameters
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseUrl+RSSClient.Constants.TopicsToURL[topic]!+escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Status code: \(response.statusCode) for URL \(urlString) URL:\(url.path!)!")
                } else if let response = response {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Response: \(response) for URL \(urlString) URL:\(url.path!)!")
                } else {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response for URL \(urlString) URL:\(url.path!)!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "No data was returned by the request URL:\(url.path!)!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            let client = RSSClient()
            client.parseXMLWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /// parse XML data
    /// :param: data XML data
    /// :param: completionHandler handle result or error
    func parseXMLWithCompletionHandler(data: NSData, completionHandler: (result: [Event], error: NSError?) -> Void) {
        dispatch_async(dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT)) {
        do {
            //print(NSString(data: data, encoding:NSUTF8StringEncoding))
            let parser = NSXMLParser(data: data)
            parser.delegate = self
            if !parser.parse() {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as XML: '\(data)'"]
                completionHandler(result: [], error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            }
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as XML: '\(data)'"]
            completionHandler(result: [], error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: self.events, error: nil)
        }
    }
    /// handle opening element
    /// :param: parser XML parser
    /// :param: elementName opening XML element
    /// :param: namespaceURI namespace URI of opening XML element
    /// :param: qName qulaified name of opening XML element
    /// :param attributeDict attributes of opening XML element
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]){
            xmlElementStack.append(elementName)
            if elementName == RSSClient.XMLResponseKeys.Item {
                id = ""
                longitude = 0.0
                latitude = 0.0
                title = ""
                summary = ""
                category = ""
                location = ""
                timestamp = NSDate()
                isItemAvailable = true
            }
            else if elementName == RSSClient.XMLResponseKeys.Description {
                isDescriptionAvailable = true
            }
    }

    /// handle closing element
    /// :param: parser XML parser
    /// :param: elementName closing XML element
    /// :param: namespaceURI namespace URI of closing XML element
    /// :param: qName qulaified name of closing XML element
    /// :param attributeDict attributes of closing XML element
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == RSSClient.XMLResponseKeys.Item {
            let privateContext = NSManagedObjectContext(
                concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator =
                CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
            privateContext.performBlockAndWait {
                self.events.append(EventRepository.createEvent(privateContext, id: self.id, title: self.title, summary: self.summary, location: self.location, latitude: self.latitude, longitude: self.longitude, weight: 1.0, timestamp: self.timestamp, category: EventRepository.getCategoryById(privateContext, id: MapCategory.NewsCategoryId)!, dataSource: EventRepository.getDataSourceById(privateContext, id: DataSource.ReutersDataSourceId)!))
                do {
                    try privateContext.save()
                }
                catch {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error creating Reuter News event: \(error)")
                }
            }
        }
        if let index = xmlElementStack.indexOf(elementName) {
            xmlElementStack.removeAtIndex(index)
        }
    }
    
    /// extract text between opening and closing XML element
    /// :param: parser XML parser
    /// :param: foundCharacters text between opening and closing XML element
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if xmlElementStack.contains(RSSClient.XMLResponseKeys.Item) {
            if isItemAvailable {
                //print("Title:\(string)")
                isItemAvailable = false
            }
            else if xmlElementStack.contains(RSSClient.XMLResponseKeys.Description) && isDescriptionAvailable {
                let range = string.rangeOfString("(Reuters) - ")
                if let index = range?.first {
                    location = string.substringToIndex(index)
                    //print("Location:\(location)")
                    if self.clientConfig.rssConfig.keywords.count == 0 || StringUtil.containsAtleastOneKeyword(summary, keywords: self.clientConfig.rssConfig.keywords) {
                        summary = string.substringFromIndex(index.advancedBy(12))
                        //print("Description:\(summary)")
                        if !location.isEmpty {
                            let locationUtil = LocationUtil()
                            let coord=locationUtil.locate(location)
                            self.latitude = coord[0]
                            self.longitude = coord[1]
                        }
                    }
                }
                isDescriptionAvailable = false
            }
            else if xmlElementStack.contains(RSSClient.XMLResponseKeys.PubDate) {
                //print("Timestamp:\(string)")
                //Sun, 22 Nov 2015 14:43:33 GMT
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                if let dt = dateFormatter.dateFromString(string) {
                    timestamp = dt
                    //print("Timestamp (typed):\(dt)")
                }
            }
            else if xmlElementStack.contains(RSSClient.XMLResponseKeys.Category) {
                //print("Category:\(string)")
                self.category = string
            }
            else if xmlElementStack.contains(RSSClient.XMLResponseKeys.GUID) {
                self.id += string
                //print("ID:\(id)")
            }
        }
    }
}
