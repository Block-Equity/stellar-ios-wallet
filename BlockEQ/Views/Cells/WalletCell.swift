//
//  WalletCollectionViewCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

class WalletCell: UICollectionViewCell, Reusable {
    @IBOutlet var holdingView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var convertedCurrencyLabel: UILabel!

    static let cellIdentifier = "WalletCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.textColor = Colors.darkGray
        currencyLabel.textColor = Colors.primaryDark
        amountLabel.textColor = Colors.darkGray
        convertedCurrencyLabel.textColor = Colors.darkGrayTransparent
    }
}
