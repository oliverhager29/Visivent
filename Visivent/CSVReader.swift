//
//  CSVReader.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/15/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// process comma separated values in a line
class CSVReader {
    /// separators
    static let Separators = NSCharacterSet(charactersInString: ",:")
    /// extract comma separate values of a line
    static func parseCSVLine(line: String) -> [String] {
        return line.componentsSeparatedByCharactersInSet(Separators)
    }
}