//
//  ContactCellStellar.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

protocol ContactCellStellarDelegate: class {
    func didSendPayment(indexPath: IndexPath)
}

class ContactStellarCell: UITableViewCell, ReusableView {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sendPaymentButton: UIButton!

    static let cellIdentifier = "ContactStellarCell"
    static let rowHeight: CGFloat = 55.0
    var indexPath: IndexPath?

    weak var delegate: ContactCellStellarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        sendPaymentButton.backgroundColor = Colors.green
        nameLabel.textColor = Colors.darkGray
    }

    @IBAction func sendPayment() {
        if let currentIndexPath = indexPath {
            delegate?.didSendPayment(indexPath: currentIndexPath)
        }
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
        nameLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
    }
}
