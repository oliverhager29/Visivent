//
//  USGSClient.swift
//  Visivent
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import Foundation
import UIKit
// MARK: - USGSClient: NSObject
/// USGS client for reading earthquake data and creating earthquake events
class USGSClient : NSObject {
    
    // MARK: Properties
    
    /// Shared session
    var session: NSURLSession
    
    /// client configuration
    var config : USGSConfig?
    var clientConfig : ClientConfig!
    
    // MARK: Initializers
    
    /// initialize session and client configuration
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        self.config = clientConfig.usgsConfig
    }

    // MARK: GET
    
    /// task for sending GET request to USGS
    /// :param: method USGS action
    /// :param: parameters URL parameters
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForGETMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */

        /* 2/3. Build the URL and configure the request */
        var urlString = Constants.RestBaseURLSecure
        urlString = fillUrl(urlString, parameters: parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
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
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                LogUtil.alert(LogUtil.ERROR, title: "Network error", message: "No data was returned by the request URL:\(url.path!)!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            USGSClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /// construct URL for getting USGS image
    /// :param: urlStr URL with place holders
    /// :param: parameters values for place holders
    /// :returns: complete URL
    func fillUrl(urlStr : String, parameters: [String : AnyObject]) -> String {
        let str = urlStr.stringByReplacingOccurrencesOfString("{\(URLKeys.Period)}", withString: parameters[URLKeys.Period] as! String)
        return str
    }
    
    // MARK: Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
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
    
    // MARK: Shared Instance
    /// singleton instance
    class func sharedInstance() -> USGSClient {
        
        struct Singleton {
            static var sharedInstance = USGSClient()
        }
        
        return Singleton.sharedInstance
    }
}