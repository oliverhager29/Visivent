//
//  FileUtil.swift
//  Visivent
//
//  Created by OLIVER HAGER on 2/6/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// File utility class
class FileUtil {
    /// copy file from bundle to documents directory
    /// :param: fileName file name without extension (that resides in the main bundle directory)
    /// :param: fileExtension file extension
    static func copyFile(fileName: String, fileExtension: String)
    {
        // construct documents directory as destination directory
        let dirPaths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let docsDir = dirPaths[0]
        let destPath = (docsDir as NSString).stringByAppendingPathComponent("/\(fileName).\(fileExtension)")
        let fileMgr = NSFileManager.defaultManager()
        // construct source directory
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileExtension) {
            // we do not overwrite (user has to uninstall app)
            if !fileMgr.fileExistsAtPath(destPath) {
                do {
                    // copy file from main bundle to documents directory
                    try fileMgr.copyItemAtPath(path, toPath: destPath)
                }
                catch {
                    LogUtil.alert(LogUtil.ERROR, title: "File error", message: "Copying failed:\(error)")
                }
            }
        }
    }
}