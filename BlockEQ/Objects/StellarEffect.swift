//
//  Transaction.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

enum StellarEffectType: String {
    case accountCreated = "Account Created"
    case sent = "Sent"
    case received = "Received"
    case trade = "Trade"
    case inflation = "Inflation Set"

    var color: UIColor {
        switch self {
        case .accountCreated:
            return Colors.primaryDark
        case .sent:
            return Colors.red
        case .received:
            return Colors.green
        case .trade:
            return Colors.blueGray
        case .inflation:
            return Colors.primaryDark
        }
    }
}

class StellarEffect: NSObject {
    var amount = ""
    var soldAmount = ""
    var boughtAmount = ""
    var createdAt: String = ""
    var type: StellarEffectType = .accountCreated
    var asset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                           assetCode: nil,
                                           assetIssuer: nil,
                                           balance: "")
    var soldAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                               assetCode: nil,
                                               assetIssuer: nil,
                                               balance: "")
    var boughtAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                                 assetCode: nil,
                                                 assetIssuer: nil,
                                                 balance: "")

    init(effect: EffectResponse) {
        super.init()
        self.setEffects(effectResponse: effect)
    }

    var formattedDate: String {
        let isoDate = createdAt.isoDate
        return isoDate.dateString
    }

    var formattedAmount: String {
        return getFormatted(amountValue: amount)
    }

    func setEffects(effectResponse: EffectResponse) {
        switch effectResponse.effectType {
        case .accountCreated: self.setUpdatedEffect(with: effectResponse)
        case .accountDebited: self.setDebitedEffect(with: effectResponse)
        case .accountCredited: self.setCreditedEffect(with: effectResponse)
        case .tradeEffect: self.setTradeEffect(with: effectResponse)
        case .accountInflationDestinationUpdated: self.setInflationEffect(with: effectResponse)
        default: break
        }
    }

    private func setUpdatedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreatedEffectResponse else {
            return
        }

        amount = updatedEffect.startingBalance
        createdAt = updatedEffect.createdAt
    }

    private func setDebitedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountDebitedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        createdAt = updatedEffect.createdAt
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
        type = .sent
    }

    private func setCreditedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreditedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        createdAt = updatedEffect.createdAt
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
        type = .received
    }

    private func setTradeEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? TradeEffectResponse else {
            return
        }

        soldAsset = StellarAsset(assetType: updatedEffect.soldAssetType,
                                 assetCode: updatedEffect.soldAssetCode,
                                 assetIssuer: updatedEffect.soldAssetIssuer,
                                 balance: "")
        boughtAsset = StellarAsset(assetType: updatedEffect.boughtAssetType,
                                   assetCode: updatedEffect.boughtAssetCode,
                                   assetIssuer: updatedEffect.boughtAssetIssuer,
                                   balance: "")
        boughtAmount = updatedEffect.boughtAmount
        soldAmount = updatedEffect.soldAmount
        createdAt = updatedEffect.createdAt
        type = .trade
    }

    private func setInflationEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountInflationDestinationUpdatedEffectResponse else {
            return
        }

        createdAt = updatedEffect.createdAt
        type = .inflation
    }

    func getFormatted(amountValue: String) -> String {
        guard let doubleValue = Double(amountValue) else {
            return "--"
        }

        return doubleValue.displayFormattedString
    }

    func formattedTransactionAmount(asset: StellarAsset) -> String {
        if type == .trade {
             if isBought(asset: asset) {
                return getFormatted(amountValue: boughtAmount)
            }
            return "(\(getFormatted(amountValue: soldAmount)))"
        } else {
            if type == .sent {
                return "(\(formattedAmount))"
            }
            return formattedAmount
        }
    }

    func color(asset: StellarAsset) -> UIColor {
        guard type == .trade else {
            return type.color
        }

        return isBought(asset: asset) ? Colors.green : Colors.red
    }

    func formattedDescription(asset: StellarAsset) -> String {
        if type == .trade {
            return String(format: "TRADE_CURRENCY_PAIR_FORMAT".localized(), soldAsset.shortCode, boughtAsset.shortCode)
        } else {
            return type.rawValue
        }
    }

    func isBought(asset: StellarAsset) -> Bool {
        return asset == boughtAsset
    }
}
