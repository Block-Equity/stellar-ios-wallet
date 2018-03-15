//
//  PaymentTransaction.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

class PaymentTransaction: NSObject {
    var amount = ""
    var isReceived = false
    var isAccountCreated = false
    var date: Date = Date()
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let dateString: String = dateFormatter.string(from: date)
        
        return dateString
    }
    
    var formattedActivity: String {
        if isAccountCreated {
            return "Account Created"
        }
        if isReceived {
            return "Received"
        }
        return "Sent"
    }
    
    var formattedAmount: String {
        guard let floatValue = Float(amount) else {
            return ""
        }
        
        return String(format: "%.2f", floatValue)
    }
}
