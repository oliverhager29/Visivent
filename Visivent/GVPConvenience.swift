//
//  GVPConvenience.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/25/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import UIKit
import Foundation
import CoreData

// MARK: - GVPClient (Convenient Resource Methods)

extension GVPClient {
    /// get volcanic activity events
    /// :param: completionHandler completion handler for handling error
    /// :returns: session task
    func getVolcanoEvents(completionHandler: (error: NSError?) -> Void) -> NSURLSessionDataTask {
        // Build the URL and configure the request
        let urlString = Constants.RestBaseURLSecure
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Error returned?
            guard (error == nil) else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "There was an error with your request: \(error)")
                return
            }
            
            // Successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Status code: \(response.statusCode) URL:\(url.path!)!")
                } else if let response = response {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Response: \(response) URL:\(url.path!)!")
                } else {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response URL:\(url.path!)!")
                }
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "No data was returned by the request URL:\(url.path!)!")
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            self.parseXMLWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        // Start the request
        task.resume()
        
        return task
    }

    /// parsing volcanic activity event data - handle opening XML element
    /// :param: parser XML parser
    /// :param: elementName XML element name
    /// :param: namespaceURI name space URI of XML element (not used)
    /// :param: qName qualified name (not used)
    /// :param: attributeDict attrubutes of XML element
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]){
        // maintain path of nested XML elements
        xmlElementStack.append(elementName)
        // each info element represents a volcanic activity and contains nested XML elements containing the data
        // initialize data to collect
        if elementName == GVPClient.XMLResponseKeys.Info {
            id = ""
            longitude = 0.0
            latitude = 0.0
            title = ""
            summary = ""
            category = "volcano"
            location = ""
        }
    }
    
    /// parsing volcanic activity event data - handle closing XML element
    /// :param: parser XML parser
    /// :param: elementName XML element name
    /// :param: namespaceURI name space URI of XML element (not used)
    /// :param: qName qualified name (not used)
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // when reaching the closing info XML element, all collected data for the volcanic activity is stored as a presistent Event object
        if elementName == GVPClient.XMLResponseKeys.Info {
            let privateContext = NSManagedObjectContext(
                concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator =
                CoreDataStackManager.sharedInstance().managedObjectContext.persistentStoreCoordinator
            // generate a unique event id
            self.id = self.idPrefix + "volcano\(self.counter)"
            privateContext.performBlockAndWait {
                // if the same event was already created
                if EventRepository.getEventById(privateContext, id: self.id) == nil {
                    EventRepository.createEvent(privateContext, id: self.id, title: self.title, summary: self.summary, location: self.location, latitude: self.latitude, longitude:             self.longitude, weight: 1.0, timestamp: self.timestamp, category: EventRepository.getCategoryById(privateContext, id: MapCategory.VolcanicActivityCategoryId)!, dataSource: EventRepository.getDataSourceById(privateContext, id: DataSource.GVPDataSourceId)!)
                }
                do {
                    try privateContext.save()
                }
                catch {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Error creating volcano event: \(error)")
                }
                self.counter++
            }
        }
        // maintain path of nested XML elements
        if let index = xmlElementStack.indexOf(elementName) {
            xmlElementStack.removeAtIndex(index)
        }
    }

    /// extract text between opening and closing XML element
    /// :param: parser XML parser
    /// :param: string characters between opening and closing XML element
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if xmlElementStack.contains(GVPClient.XMLResponseKeys.Sent) {
            self.idPrefix = string
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            if let dt = dateFormatter.dateFromString(string) {
                timestamp = dt
            }
        }
        else if xmlElementStack.contains(GVPClient.XMLResponseKeys.Info) {
            // activity description (remove line breaks)
            if xmlElementStack.contains(GVPClient.XMLResponseKeys.Description) {
                if string.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ")) != "\n" {
                    self.summary += string.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n"))
                }
            }
                // title for activity
            else if xmlElementStack.contains(GVPClient.XMLResponseKeys.Headline) {
                self.title = string
            }
                // location of activity
            else if xmlElementStack.contains(GVPClient.XMLResponseKeys.AreaDesc) {
                self.location = string
            }
                // coordinates
            else if xmlElementStack.contains(GVPClient.XMLResponseKeys.Circle) {
                let commaRange: Range<String.Index> = string.rangeOfString(",")!
                let latStr = string.substringToIndex(commaRange.startIndex)
                let beginOfLongitude = commaRange.endIndex
                let blankRange: Range<String.Index> = string.rangeOfString(" ")!
                let endOfLongitude = blankRange.startIndex.predecessor()
                let lonStr = string.substringWithRange(beginOfLongitude ... endOfLongitude)
                if let latitude = Double(latStr) {
                    self.latitude = latitude
                }
                if let longitude = Double(lonStr) {
                    self.longitude = longitude
                }
            }
        }
    }
    
}