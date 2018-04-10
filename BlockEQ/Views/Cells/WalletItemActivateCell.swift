//
//  WalletItemActivateCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class WalletItemActivateCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    static let cellIdentifier = "WalletItemActivateCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = Colors.white
        contentView.backgroundColor = Colors.green
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
        contentView.backgroundColor =  selected ? Colors.greenTransparent : Colors.green
        //titleLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
    }
}
