//
//  OffersCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-28.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class OffersCell: UITableViewCell {
    @IBOutlet weak var offerLabel: UILabel!
    
    static let cellIdentifier = "OffersCell"
    static let rowHeight: CGFloat = 55.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        offerLabel.textColor = Colors.darkGray
    }
}
