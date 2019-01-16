//
//  OrderBookEmptyCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-30.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

class OrderBookEmptyCell: UITableViewCell, Reusable, NibLoadable {
    @IBOutlet weak var label: UILabel!

    static let rowHeight: CGFloat = 100.0

    override func awakeFromNib() {
        super.awakeFromNib()

        label.textColor = Colors.darkGrayTransparent
        label.text = "EMPTY_OFFERS".localized()
    }
}
