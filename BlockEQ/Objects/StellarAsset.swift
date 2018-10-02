//
//  StellarObject.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

class StellarAsset: NSObject {
    var balance = ""
    var assetType = ""
    var assetCode: String?
    var assetIssuer: String?

    init(assetType: String, assetCode: String?, assetIssuer: String?, balance: String) {
        self.assetType = assetType
        self.assetCode = assetCode
        self.assetIssuer = assetIssuer
        self.balance = balance
    }

    var formattedBalance: String {
        return balance.decimalFormatted
    }

    var shortCode: String {
        if assetType == AssetTypeAsString.NATIVE {
            return "XLM"
        }

        if let code = assetCode {
            return code
        }

        return ""
    }

    var isNative: Bool {
        if assetType == AssetTypeAsString.NATIVE {
            return true
        }

        return false
    }

    var hasZeroBalance: Bool {
        if let balance = Double(balance) {
            return balance.isZero
        }

        return true
    }

    static func == (lhs: StellarAsset, rhs: StellarAsset) -> Bool {
        return lhs.assetType == rhs.assetType && lhs.assetCode == rhs.assetCode && lhs.assetIssuer == rhs.assetIssuer
    }
}
