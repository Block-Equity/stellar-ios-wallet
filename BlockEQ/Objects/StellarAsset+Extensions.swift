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
        let metadata = AssetMetadata(shortCode: shortCode)
        return AssetHeaderView.ViewModel(image: metadata.image,
                                         assetTitle: metadata.displayName,
                                         assetSubtitle: metadata.subtitleWithIssuer)
    }

    var priceViewModel: AssetPriceView.ViewModel {
        let assetBalance = self.hasZeroBalance ? "NOT_AVAILABLE_SHORTFORM".localized() : balance
        let assetPrice = ""
        return AssetPriceView.ViewModel(amount: assetBalance.displayFormatted, price: assetPrice)
    }

    var issuerViewModel: AssetIssuerView.ViewModel {
        let nativeModel = AssetIssuerView.ViewModel(issuerTitle: "DESCRIPTION_TITLE".localized(),
                                                    issuerDescription: "LUMEN_DESCRIPTION".localized(),
                                                    addressTitle: "NOTES_TITLE".localized(),
                                                    addressDescription: "LUMEN_NOTES".localized())

        let metadata = AssetMetadata(shortCode: self.shortCode)
        let issuerTitle = String(format: "ISSUER_TITLE_FORMAT".localized(), metadata.issuerName ?? "")

        let nonNativeModel = AssetIssuerView.ViewModel(issuerTitle: issuerTitle,
                                                       issuerDescription: metadata.displayName,
                                                       addressTitle: "ISSUER_ADDRESS".localized(),
                                                       addressDescription: metadata.issuerAddress ?? "")

        return self.isNative ? nativeModel : nonNativeModel
    }
}
