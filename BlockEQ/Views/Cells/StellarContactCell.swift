//
//  ContactCellStellar.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol StellarContactCellDelegate: class {
    func didRequestPayment(indexPath: IndexPath)
}

class StellarContactCell: UITableViewCell, NibReusable {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sendPaymentButton: UIButton!

    static let rowHeight: CGFloat = 55.0
    var indexPath: IndexPath?

    weak var delegate: StellarContactCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        sendPaymentButton.backgroundColor = Colors.green
        nameLabel.textColor = Colors.darkGray
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

// MARK: - IBActions
extension StellarContactCell {
    @IBAction func sendPayment() {
        if let currentIndexPath = indexPath {
            delegate?.didRequestPayment(indexPath: currentIndexPath)
        }
    }
}
