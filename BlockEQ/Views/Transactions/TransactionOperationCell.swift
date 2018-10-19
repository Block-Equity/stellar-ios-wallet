//
//  TransactionOperationsCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class TransactionOperationCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sequenceNumber: UILabel!

    static let cellHeight = CGFloat(60.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    func setupStyle() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = Colors.transactionCellDarkGray

        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = Colors.transactionCellMediumGray

        sequenceNumber.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        sequenceNumber.textColor = Colors.transactionCellMediumGray
        sequenceNumber.setCharacterSpacing(kern: -0.3)
    }
}

extension UILabel {
    func setCharacterSpacing(kern: Double) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: kern,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
