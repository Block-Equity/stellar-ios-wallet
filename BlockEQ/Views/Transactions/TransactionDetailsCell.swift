//
//  TransactionDetailsCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class TransactionDetailsCell: UICollectionViewCell, NibReusable {
    struct ViewModel {
        let sourceAccount: String
        let transactionId: String
        let amount: String
        let date: String
        let sequenceNumber: String
        let fee: String
        let operationCount: String
        let memoType: String?
        let memoData: String?
        let signers: [String]
    }

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sourceAccountTitleLabel: UILabel!
    @IBOutlet weak var sourceAccountLabel: UIInsetLabel!
    @IBOutlet weak var transactionIdTitleLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sequenceNumberTitleLabel: UILabel!
    @IBOutlet weak var sequenceNumberLabel: UILabel!
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var operationTitleLabel: UILabel!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var transactionDetailsContainerView: UIView!
    @IBOutlet weak var dataStackView: UIStackView!

    static let cellHeight = CGFloat(325.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sourceAccountLabel.layer.masksToBounds = true
        sourceAccountLabel.layer.cornerRadius = sourceAccountLabel.frame.height / 2
    }

    func setupStyle() {
        let primaryHeaderFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let secondaryTextFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let primaryTextFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let primaryTextColor = Colors.white

        sourceAccountLabel.backgroundColor = Colors.primaryDark

        memoTitleLabel.font = primaryHeaderFont
        sourceAccountTitleLabel.font = primaryHeaderFont
        transactionIdTitleLabel.font = primaryHeaderFont
        transactionIdLabel.numberOfLines = 2

        sourceAccountLabel.font = primaryTextFont
        sourceAccountLabel.textColor = primaryTextColor

        amountTitleLabel.font = secondaryTextFont
        dateTitleLabel.font = secondaryTextFont
        feeTitleLabel.font = secondaryTextFont
        operationTitleLabel.font = secondaryTextFont
        sequenceNumberTitleLabel.font = secondaryTextFont

        amountLabel.font = secondaryTextFont
        amountLabel.textColor = Colors.transactionCellDarkGray

        dateLabel.font = secondaryTextFont
        dateLabel.textColor = Colors.transactionCellDarkGray

        sequenceNumberLabel.font = secondaryTextFont
        sequenceNumberLabel.textColor = Colors.transactionCellDarkGray

        feeLabel.font = secondaryTextFont
        feeLabel.textColor = Colors.transactionCellDarkGray

        operationLabel.font = secondaryTextFont
        operationLabel.textColor = Colors.transactionCellDarkGray

        memoLabel.font = secondaryTextFont
        memoLabel.textColor = Colors.transactionCellDarkGray

        transactionDetailsContainerView.topBorder(with: Colors.transactionCellBorderGray, width: 1)
        transactionDetailsContainerView.bottomBorder(with: Colors.transactionCellBorderGray, width: 1)
    }

    func update(with viewModel: ViewModel) {
        sourceAccountLabel.text = viewModel.sourceAccount
        transactionIdLabel.text = viewModel.transactionId
        feeLabel.text = viewModel.fee
        amountLabel.text = viewModel.amount
        dateLabel.text = viewModel.date
        memoLabel.text = viewModel.memoData
        memoTitleLabel.text = viewModel.memoType?.uppercased()
        operationLabel.text = viewModel.operationCount
        sequenceNumberLabel.text = viewModel.sequenceNumber
    }
}
