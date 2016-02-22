//
//  GVPClient.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/25/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Global Volcanism Program (GVP) client reads weekly volcanic events via CAP (Common Alerting Protocol) feeds that is in XML
/// The class implements an XML parser and extracts the key attribute out of the CAP data.
class GVPClient : NSObject, NSXMLParserDelegate {
    
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    var config : GVPConfig?
    var clientConfig : ClientConfig!
    
    /// state of the XML parsing
    var xmlElementStack : [String] = []
    var id = ""
    var longitude = 0.0
    var latitude = 0.0
    var title = ""
    var summary = ""
    var category = ""
    var location = ""
    var timestamp = NSDate()
    var counter = 0
    var idPrefix = ""

    /// image cache back by files stored in local file system
    /// this is used for reading images of world-wide volcanoes
    /// the locations of those volcanos is read in via a file that uses GVP data with webcam links from other Website
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        self.config = clientConfig.gvpConfig
    }
    
    // MARK: Helpers
    
    /// Parses passed XML and creates persistent Event objects from it
    /// :param: data XML data
    /// :param: completionHandler handles errors
    func parseXMLWithCompletionHandler(data: NSData, completionHandler: (error: NSError?) -> Void) {
        // parse XML
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        if !parser.parse() {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as XML: '\(data)'"]
            completionHandler(error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(error: nil)
    }
    

    /// get photo by URL
    /// :param: url URL for retrieving image
    func getImageByUrl(url: String, completionHandler: (result: UIImage?, error: NSError?) -> Void) {
        GVPClient.sharedInstance().taskForGETImage(url) {
            imageData, error in
            if let error = error {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: error.description)
                completionHandler(result: nil, error: error)
            }
            else {
                completionHandler(result: UIImage(data: imageData!), error: nil)
            }
        }
    }
    
    /// task for downloading image
    /// :param: url URL to image
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForGETImage(url: String,completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        if let cachedImage = Caches.imageCache.imageWithIdentifier(url) as UIImage? {
            completionHandler(imageData: UIImagePNGRepresentation(cachedImage), error: nil)
        }
        var urlToDownload = url
        if let startIndex = url.characters.indexOf("#") {
            urlToDownload = url.substringFromIndex(startIndex.successor())
        }
        // Build the URL and configure the request
        let urlObj = NSURL(string: urlToDownload)!
        let request = NSMutableURLRequest(URL: urlObj)
        request.timeoutInterval = NSTimeInterval(360)
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Error?
            guard (error == nil) else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "There was an error with your request")
                return
            }
            
            // Successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Status code: \(response.statusCode) URL:\(urlObj.path!)!")
                } else if let response = response {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response! Response: \(response) URL:\(urlObj.path!)!")
                } else {
                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "Your request returned an invalid response URL:\(urlObj.path!)!")
                }
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "No data was returned by the request URL:\(urlObj.path!)!")
                return
            }
            
            // store image data in file and memory cache
            Caches.imageCache.storeImage(UIImage(data: data), withIdentifier: url)
            completionHandler(imageData: data, error: nil)
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    /// delete image by URL
    func deleteImage(url: String) {
        Caches.imageCache.storeImage(nil, withIdentifier: url)
    }
    
    /// Shared Instance
    class func sharedInstance() -> GVPClient {
        
        struct Singleton {
            static var sharedInstance = GVPClient()
        }
        
        return Singleton.sharedInstance
    }
}