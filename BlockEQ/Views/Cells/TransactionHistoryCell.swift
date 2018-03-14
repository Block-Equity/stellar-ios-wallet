//
//  TransactionHistoryCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    static let cellIdentifier = "TransactionHistoryCell"
    static let rowHeight: CGFloat = 80.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        activityLabel.textColor = Colors.black
        amountLabel.textColor = Colors.black
        dateLabel.textColor = Colors.blackTransparent
    }
    
}
