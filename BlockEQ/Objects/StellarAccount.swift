//
//  StellarAccount.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class StellarAccount: NSObject {
    var accountId = ""
    var assets: [StellarAsset] = []
    var inflationDestination: String?
    var totalTrustlines: Int = 0
    var totalOffers: Int = 0
    var totalSigners: Int = 0
    var totalBaseReserve: Int = 1
    
    var baseReserve: Double {
        return Double(totalBaseReserve) * 0.5
    }
    
    var trustlines: Double {
        return Double(totalTrustlines) * 0.5
    }
    
    var offers: Double {
        return Double(totalOffers) * 0.5
    }
    
    var signers: Double {
        return Double(totalSigners) * 0.5
    }
    
    var formattedBaseReserve: String {
        return String(format: "%.2f", baseReserve)
    }
    
    var formattedTrustlines: String {
        return String(format: "%.2f", trustlines)
    }
    
    var formattedOffers: String {
        return String(format: "%.2f", offers)
    }
    
    var formattedSigners: String {
        return String(format: "%.2f", signers)
    }
    
    var minBalance: Double {
        return baseReserve + trustlines + offers + signers
    }
    
    var formattedMinBalance: String {
        return String(format: "%.4f", minBalance)
    }
    
    var availableBalance: Double {
        var totalBalance = 0.00
        for asset in assets {
            if asset.assetType == AssetTypeAsString.NATIVE  {
                if let assetBalance = Double(asset.balance) {
                   totalBalance = assetBalance
                }
            }
        }

        let calculatedBalance = totalBalance - minBalance
        
        if calculatedBalance >= 0.0 {
            return calculatedBalance
        }
        return totalBalance
    }
    
    var formattedAvailableBalance: String {
        return String(format: "%.4f", availableBalance)
    }
}
