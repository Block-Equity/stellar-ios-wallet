//
//  StellarAccount.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class StellarAccount: NSObject {
    var accountId = ""
    var balance = ""
    
    var formattedBalance: String {
        guard let floatValue = Float(balance) else {
            return ""
        }
        
        return String(format: "%.2f", floatValue)
    }
}
