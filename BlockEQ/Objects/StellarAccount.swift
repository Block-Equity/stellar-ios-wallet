//
//  StellarAccount.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class StellarAccount {
    var accountId = ""
    var assets: [StellarAsset] = []
    var inflationDestination: String?
    var totalTrustlines: Int = 0
    var totalOffers: Int = 0
    var totalSigners: Int = 0
    var totalBaseReserve: Int = 1
    var transactions: [StellarTransaction] = []

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
        return baseReserve.displayFormattedString
    }

    var formattedTrustlines: String {
        return trustlines.displayFormattedString
    }

    var formattedOffers: String {
        return offers.displayFormattedString
    }

    var formattedSigners: String {
        return signers.displayFormattedString
    }

    var minBalance: Double {
        return baseReserve + trustlines + offers + signers
    }

    var formattedMinBalance: String {
        return minBalance.displayFormattedString
    }

    var formattedAvailableBalance: String {
        return availableBalance.displayFormattedString
    }

    var availableBalance: Double {
        var totalBalance = 0.00
        for asset in assets where asset.assetType == AssetTypeAsString.NATIVE {
            if let assetBalance = Double(asset.balance) {
                totalBalance = assetBalance
            }
        }

        let calculatedBalance = totalBalance - minBalance

        if calculatedBalance >= 0.0 {
            return calculatedBalance
        }
        return totalBalance
    }
}
