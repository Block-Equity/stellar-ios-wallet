//
//  StellarEffect.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarEffect {
    public let identifier: String
    public private(set) var amount = ""
    public private(set) var soldAmount = ""
    public private(set) var boughtAmount = ""
    public private(set) var createdAt: String = ""
    public private(set) var type: EffectType = .accountCreated
    public private(set) var asset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                           assetCode: nil,
                                           assetIssuer: nil,
                                           balance: "")

    public private(set) var assetPair = StellarAssetPair(buying: StellarAsset.lumens, selling: StellarAsset.lumens)

    init(response: EffectResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.type = response.effectType

        switch response.effectType {
        case .accountCreated: self.setUpdatedEffect(with: response)
        case .accountDebited: self.setDebitedEffect(with: response)
        case .accountCredited: self.setCreditedEffect(with: response)
        case .tradeEffect: self.setTradeEffect(with: response)
        case .accountInflationDestinationUpdated: self.setInflationEffect(with: response)
        default: break
        }
    }

    private func setUpdatedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreatedEffectResponse else {
            return
        }

        amount = updatedEffect.startingBalance
    }

    private func setDebitedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountDebitedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
    }

    private func setCreditedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreditedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
    }

    private func setTradeEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? TradeEffectResponse else {
            return
        }

        let selling = StellarAsset(assetType: updatedEffect.soldAssetType,
                                         assetCode: updatedEffect.soldAssetCode,
                                         assetIssuer: updatedEffect.soldAssetIssuer,
                                         balance: "")

        let buying = StellarAsset(assetType: updatedEffect.boughtAssetType,
                                        assetCode: updatedEffect.boughtAssetCode,
                                        assetIssuer: updatedEffect.boughtAssetIssuer,
                                        balance: "")

        self.assetPair = StellarAssetPair(buying: buying, selling: selling)

        boughtAmount = updatedEffect.boughtAmount
        soldAmount = updatedEffect.soldAmount
    }

    private func setInflationEffect(with effectResponse: EffectResponse) {
    }

    public func isBought(asset: StellarAsset) -> Bool {
        return asset == self.assetPair.buying
    }
}
