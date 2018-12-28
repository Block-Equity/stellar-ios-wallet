//
//  TransactionHistoryCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import Reusable

final class TransactionHistoryCell: UITableViewCell, NibReusable {
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var transactionDisplayView: UIView!

    static let rowHeight: CGFloat = 65.0

    override func awakeFromNib() {
        super.awakeFromNib()

        activityLabel.textColor = Colors.black
        amountLabel.textColor = Colors.black
        dateLabel.textColor = Colors.blackTransparent
    }

    func update(with asset: StellarAsset, effect: StellarEffect) {
        amountLabel.text = effect.formattedTransactionAmount(asset: asset)
        dateLabel.text = effect.formattedDate
        activityLabel.text = effect.formattedDescription(asset: asset)
        transactionDisplayView.backgroundColor = effect.color

        accessoryType = WalletDataSource.supportedDetails.contains(effect.type) ? .disclosureIndicator : .none
        contentView.bottomBorder(with: UIColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1.000), width: 1)
    }
}
