//
//  TransactionSignatureCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class TransactionSignatureCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var signatureLabel: UILabel!

    static let cellHeight = CGFloat(44.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    func setupStyle() {
        signatureLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        signatureLabel.setCharacterSpacing(kern: -0.4)
        signatureLabel.textColor = Colors.transactionCellDarkGray
    }

    func update(with signer: String) {
        signatureLabel.text = signer
    }
}
