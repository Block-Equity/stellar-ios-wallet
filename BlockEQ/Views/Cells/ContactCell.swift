//
//  ContactCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol ContactCellDelegate: class {
    func didSelectAddToAddressBook(indexPath: IndexPath)
}

class ContactCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressButton: UIButton!
    
    var delegate: ContactCellDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "ContactCell"
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
        addressButton.backgroundColor = Colors.shadowGray
    }
}
