//
//  WordSuggestionCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-12.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class WordSuggestionCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    static let cellIdentifier = "WordSuggestionCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = Colors.white
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? Colors.lightGray : nil
            titleLabel.textColor = isHighlighted ? Colors.darkGray: Colors.white
        }
    }
}
