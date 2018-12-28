//
//  OrderBookCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

class OrderBookCell: UITableViewCell, NibReusable {
    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option3Label: UILabel!

    static let rowHeight: CGFloat = 44.0

    override func awakeFromNib() {
        super.awakeFromNib()

        option1Label.textColor = Colors.darkGray
        option2Label.textColor = Colors.darkGray
        option3Label.textColor = Colors.darkGray
    }
}
