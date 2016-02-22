//
//  KeywordTableViewCell.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/11/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// Keyword table view cell
class KeywordTableViewCell : UITableViewCell {
    /// label of table view cell (the keyword)
    @IBOutlet weak var keywordLabel: UILabel!
    /// remove button (to remove key word from list of keywords)
    @IBOutlet weak var removeKeyword: UIButton!
}