//
//  OrderBookEmptyCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-30.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class OrderBookEmptyCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    static let cellIdentifier = "OrderBookEmptyCell"
    static let rowHeight: CGFloat = 100.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.textColor = Colors.darkGrayTransparent
    }
}
