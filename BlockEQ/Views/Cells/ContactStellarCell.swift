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
