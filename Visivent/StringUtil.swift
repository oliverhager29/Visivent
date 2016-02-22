//
//  StringUtil.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/17/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// String utility functions
class StringUtil {
    /// Empty string constant
    static let EmptyString = ""
    /// Blank string constant
    static let BlankString = " "
    /// comma string constant
    static let CommaString = ","
    /// double quote string constant
    static let DoubleQuoteString = "\""
    
    /// check whether keyword is contained in list of keywords (ignoreing case)
    /// :param: string keyword
    /// :param: keywords keywords
    /// :returns: true if keyword is contained in keywords, false otheriwse
    static func containsAtleastOneKeyword(string: String, keywords: NSArray) -> Bool {
        let lowerCaseString = string.lowercaseString
        for keyword in keywords {
            if lowerCaseString.containsString(keyword.lowercaseString) {
                return true
            }
        }
        return false
    }
}