//
//  StellarAccount.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

extension StellarAccount {
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

    var formattedMinBalance: String {
        return minBalance.displayFormattedString
    }

    var formattedAvailableBalance: String {
        return availableBalance.displayFormattedString
    }

    func formattedAvailableBalance(for asset: StellarAsset) -> String {
        return String(format: "AVAILABLE_BALANCE_FORMAT_STRING".localized(),
                      availableBalance.tradeFormattedString,
                      asset.shortCode
        )
    }
}
