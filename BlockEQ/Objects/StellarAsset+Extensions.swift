//
//  StellarAsset+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension StellarAsset {
    var headerViewModel: AssetHeaderView.ViewModel {
        let metadata = AssetMetadata(shortCode: shortCode, issuer: assetIssuer)
        let lowerShortcode = shortCode.lowercased()
        return AssetHeaderView.ViewModel(image: metadata.image,
                                         imageURL: BlockEQURL.assetIcon(lowerShortcode).url,
                                         assetTitle: metadata.displayName,
                                         assetSubtitle: metadata.subtitleWithIssuer)
    }

    var priceViewModel: AssetPriceView.ViewModel {
        let assetBalance = self.hasZeroBalance ? "NOT_AVAILABLE_SHORTFORM".localized() : balance
        let assetPrice = ""
        return AssetPriceView.ViewModel(amount: assetBalance.displayFormatted, price: assetPrice)
    }

    var issuerViewModel: AssetIssuerView.ViewModel {
        let metadata = AssetMetadata(shortCode: shortCode, issuer: assetIssuer)

        let issuerName = metadata.issuerName ?? ""
        var titleString = String(format: "ISSUER_TITLE_FORMAT".localized(), issuerName)

        if issuerName.isEmpty {
            titleString = "ASSET_NAME_TITLE".localized()
        }

        let nativeModel = AssetIssuerView.ViewModel(issuerTitle: "DESCRIPTION_TITLE".localized(),
                                                    issuerDescription: metadata.description ?? metadata.displayName,
                                                    addressTitle: "NOTES_TITLE".localized(),
                                                    addressDescription: "LUMEN_NOTES".localized())

        let nonNativeModel = AssetIssuerView.ViewModel(issuerTitle: titleString,
                                                       issuerDescription: metadata.description ?? metadata.displayName,
                                                       addressTitle: "ISSUER_ADDRESS".localized(),
                                                       addressDescription: metadata.issuerAddress ?? "")

        return self.isNative ? nativeModel : nonNativeModel
    }
}
