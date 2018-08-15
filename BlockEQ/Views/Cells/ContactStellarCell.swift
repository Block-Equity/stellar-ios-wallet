//
//  ContactCellStellar.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol ContactCellStellarDelegate: class {
    func didSendPayment(indexPath: IndexPath)
}

class ContactStellarCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sendPaymentButton: UIButton!

    var delegate: ContactCellStellarDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "ContactStellarCell"
    static let rowHeight: CGFloat = 55.0
    
    @IBAction func sendPayment() {
        if let currentIndexPath = indexPath {
            delegate?.didSendPayment(indexPath: currentIndexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        sendPaymentButton.backgroundColor = Colors.green
    }
}
