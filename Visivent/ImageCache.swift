//
//  ImageCache.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/30/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit

/// Image cache
/// images are store in memory and as files in the documents directory
class ImageCache {
    /// in memory cache
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    /// lookup image by identifier (usually URL)
    /// images are first looked up in the memory and if not exist read the documents directory
    /// :param: identifier usually URL
    /// :returns: image
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    /// store image with identifier in memory and as file in the documents directory
    /// :param: image image to store
    /// :param: identifier usually URL
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch {
                LogUtil.alert(LogUtil.ERROR, title: "File error", message: "removing file failed: \(path)")
            }
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    /// convert URL to file name
    /// :param: url URL
    /// :returns: file name
    func convertUrlToFileName(url: String) -> String {
        var str = url.stringByReplacingOccurrencesOfString("https://", withString: "")
        str = str.stringByReplacingOccurrencesOfString("http://", withString: "")
        str = str.stringByReplacingOccurrencesOfString("/", withString: "_")
        str = str.stringByReplacingOccurrencesOfString(".jpg", withString: "@jpg")
        str = str.stringByReplacingOccurrencesOfString(".", withString: "_")
        str = str.stringByReplacingOccurrencesOfString(" ", withString: "_")
        str = str.stringByReplacingOccurrencesOfString("@jpg", withString: ".jpg")
        return str
    }
    
    /// create path to file from identifier
    /// :param: identifier usually URL
    /// :returns: path to file
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let fullURL = documentsDirectoryURL!.URLByAppendingPathComponent(convertUrlToFileName(identifier))
        
        return fullURL.path!
    }
}