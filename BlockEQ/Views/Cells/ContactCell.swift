//
//  ContactCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol ContactCellDelegate: class {
    func didSelectAddToAddressBook(indexPath: IndexPath)
}

class ContactCell: UITableViewCell, NibReusable {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressButton: UIButton!

    weak var delegate: ContactCellDelegate?
    var indexPath: IndexPath?
    static let rowHeight: CGFloat = 55.0

    @IBAction func addToAddressBook() {
        if let currentIndexPath = indexPath {
            delegate?.didSelectAddToAddressBook(indexPath: currentIndexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    func setupView() {
        addressButton.backgroundColor = Colors.secondaryDark
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
