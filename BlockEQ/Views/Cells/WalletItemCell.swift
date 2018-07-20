//
//  WalletItem.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol WalletItemCellDelegate: class {
    func didRemoveAsset(indexPath: IndexPath)
    func didChangeInflation()
}

class WalletItemCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var tokenInitialLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var setInflationButton: UIButton!
    @IBOutlet var updateInflationButton: UIButton!
    @IBOutlet var removeAssetButton: UIButton!
    
    var delegate: WalletItemCellDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "WalletItemCell"
    
    @IBAction func removeAsset() {
        if let currentIndexPath = indexPath {
            delegate?.didRemoveAsset(indexPath: currentIndexPath)
        }
    }
    
    @IBAction func changeInflation() {
        delegate?.didChangeInflation()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        removeAssetButton.backgroundColor = Colors.red
        setInflationButton.backgroundColor = Colors.red
        updateInflationButton.backgroundColor = Colors.green
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
