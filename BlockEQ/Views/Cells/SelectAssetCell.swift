//
//  SelectAssetCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-16.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class SelectAssetCell: UITableViewCell, ReusableView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var tokenInitialLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var disclosureIndicatorImageView: UIImageView!

    static let cellIdentifier = "SelectAssetCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    func setupView() {
        disclosureIndicatorImageView.tintColor = Colors.shadowGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        setRowColor(selected: selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        setRowColor(selected: highlighted)
    }

    func setRowColor(selected: Bool) {
        contentView.backgroundColor =  selected ? Colors.lightBlue : Colors.white
        titleLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
        amountLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
    }
}
