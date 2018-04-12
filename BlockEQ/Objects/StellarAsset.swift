//
//  StellarObject.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class StellarAsset: NSObject {
    var balance = ""
    var assetType = ""
    var assetCode: String?
    var assetIssuer: String?
    
    var formattedBalance: String {
        guard let floatValue = Float(balance) else {
            return ""
        }
        
        return String(format: "%.2f", floatValue)
    }
    
    var shortCode: String {
        if assetType == AssetTypeAsString.NATIVE {
            return "XLM"
        } else {
            return assetCode!
        }
    }
}
