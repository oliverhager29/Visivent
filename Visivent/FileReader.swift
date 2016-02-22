  //
//  FileReader.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/15/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// This file reader reads a text file line by line. Each line gets processed (e.g comma separate values are extracted).
/// It falls back the standard C library because the Swift library functions have a large memory footprint/memory leaks preventing reading millions of lines.
class FileReader {
    /// end of file reached
    var eofReached = false
    /// line counter
    var counter = 0
    /// file handle
    let fileHandle: UnsafeMutablePointer<FILE>
    /// closure to process line (e.g comma separate values are extracted)
    var processLine : ( (Int, String) -> () )?
    
    /// initialize file handle and closure
    init (fileName : String, processLine : ( (Int, String) -> () )) {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") {
            let pathStr = path as NSString
            self.fileHandle = fopen(pathStr.UTF8String, NSString(string: "rb").UTF8String)
            self.processLine = processLine
        }
        else {
            self.processLine = nil
            self.fileHandle = nil
            LogUtil.alert(LogUtil.ERROR, title: "File error", message: "Error reading file '\(fileName).txt': No such file or directory")
        }
    }

    /// close file handle
    deinit {
        fclose(self.fileHandle)
    }
    
    /// go to next line
    func nextLine() -> String {
        var nextChar: UInt8 = 0
        var stringSoFar = NSString(string: "")
        var eolReached = false
        while (self.eofReached == false) && (eolReached == false) {
            if fread(&nextChar, 1, 1, self.fileHandle) == 1 {
                switch nextChar & 0xFF {
                case 13, 10 : // CR, LF
                    eolReached = true
                case 0...127 : // Keep it in ASCII
                    if let tmpStr = NSString(bytes:&nextChar, length:1, encoding: NSASCIIStringEncoding) as NSString? {
                        stringSoFar = stringSoFar.stringByAppendingString(tmpStr as String)
                    }
                default :
                    stringSoFar = stringSoFar.stringByAppendingString("<\(nextChar)>")
                }
            } else { // EOF or error
                self.eofReached = true
            }
        }
        return stringSoFar as String
    }
    
    /// process line by line using the closure
    func processFile() {
        while !self.eofReached {
            autoreleasepool({
            let line = self.nextLine()
            if let processLine = self.processLine {
                processLine(counter, line)
            }
            self.counter++
            })
        }
    }
}