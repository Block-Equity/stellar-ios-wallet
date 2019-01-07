//
//  StellarAccount.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension StellarAccount {
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

    var availableAssets: [StellarAsset] {
        let existing = Set(assets)

        let staticMetadataList = AssetMetadata.staticAssetCodes.map { AssetMetadata(shortCode: $0) }
        let staticAssets = Set(staticMetadataList.map {
            StellarAsset(assetCode: $0.shortCode, issuer: $0.issuerAddress ?? "")
        })

        return Array(staticAssets.subtracting(existing))
    }

    func formattedAvailableBalance(for asset: StellarAsset) -> String {
        let balance = availableBalance(for: asset)
        return String(format: "AVAILABLE_BALANCE_FORMAT_STRING".localized(),
                      balance.tradeFormattedString,
                      asset.shortCode
        )
    }

    func firstAssetExcluding(_ asset: StellarAsset?) -> StellarAsset? {
        let filteredAssets = assets.filter { $0 != asset }
        return filteredAssets.first
    }
}
