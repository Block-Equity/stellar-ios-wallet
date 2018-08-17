//
//  WalletItemActivateCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol WalletItemActivateCellDelegate: class {
    func didAddAsset(indexPath: IndexPath)
}

class WalletItemActivateCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var addAssetButton: UIButton!
    
    var delegate: WalletItemActivateCellDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "WalletItemActivateCell"
    
    @IBAction func addAsset() {
        if let currentIndexPath = indexPath {
            delegate?.didAddAsset(indexPath: currentIndexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        addAssetButton.backgroundColor = Colors.secondaryDark
        titleLabel.textColor = Colors.white
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
        addAssetButton.backgroundColor = Colors.secondaryDark
    }
}
