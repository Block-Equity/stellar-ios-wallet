//
//  TransactionDetailsBasicHeader.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class TransactionDetailsBasicHeader: UICollectionReusableView, NibReusable {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    func setupStyle() {
        leftLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        rightLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        leftLabel.textColor = Colors.transactionCellMediumGray
        rightLabel.textColor = Colors.transactionCellDarkGray

        leftLabel.text = "LEDGER_TITLE".localized().uppercased()
        rightLabel.text = "00000000"

        leftLabel.text = nil
        rightLabel.text = nil
    }
}
