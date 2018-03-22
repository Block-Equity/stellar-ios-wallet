//
//  TransactionHistoryCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var transactionDisplayView: UIView!
    
    static let cellIdentifier = "TransactionHistoryCell"
    static let rowHeight: CGFloat = 80.0
    
    enum TransactionType: String {
        case sent = "Sent"
        case received = "Received"
        case created = "Account Funded"
        
        var color: UIColor {
            switch self {
            case .sent:
                return Colors.red
            case .received:
                return Colors.green
            default:
                return Colors.primaryDark
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        activityLabel.textColor = Colors.black
        amountLabel.textColor = Colors.black
        dateLabel.textColor = Colors.blackTransparent
    }
    
    func setTitle(isAccountCreated: Bool, isPaymentReceived: Bool) {
        var transactionType: TransactionType!
        if isAccountCreated {
            transactionType = .created
        } else if isPaymentReceived {
            transactionType = .received
        } else {
            transactionType = .sent
        }
        
        activityLabel.text = transactionType.rawValue
        transactionDisplayView.backgroundColor = transactionType.color
    }
}
