//
//  Transaction.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-06.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
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
    var asset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var soldAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var boughtAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var type: StellarEffectType = .accountCreated
    
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
        case .accountCreated:
            let updatedEffect = effectResponse as! AccountCreatedEffectResponse
            amount = updatedEffect.startingBalance
            createdAt = updatedEffect.createdAt
        case .accountDebited:
            let updatedEffect = effectResponse as! AccountDebitedEffectResponse
            amount = updatedEffect.amount
            createdAt = updatedEffect.createdAt
            asset = StellarAsset(assetType: updatedEffect.assetType, assetCode: updatedEffect.assetCode, assetIssuer:updatedEffect.assetIssuer, balance: "")
            type = .sent
        case .accountCredited:
            let updatedEffect = effectResponse as! AccountCreditedEffectResponse
            amount = updatedEffect.amount
            createdAt = updatedEffect.createdAt
            asset = StellarAsset(assetType: updatedEffect.assetType, assetCode: updatedEffect.assetCode, assetIssuer:updatedEffect.assetIssuer, balance: "")
            type = .received
        case .tradeEffect:
            let updatedEffect = effectResponse as! TradeEffectResponse
            soldAsset = StellarAsset(assetType: updatedEffect.soldAssetType, assetCode: updatedEffect.soldAssetCode, assetIssuer:updatedEffect.soldAssetIssuer, balance: "")
            boughtAsset = StellarAsset(assetType: updatedEffect.boughtAssetType, assetCode: updatedEffect.boughtAssetCode, assetIssuer:updatedEffect.boughtAssetIssuer, balance: "")
            boughtAmount = updatedEffect.boughtAmount
            soldAmount = updatedEffect.soldAmount
            createdAt = updatedEffect.createdAt
            type = .trade
        case .accountInflationDestinationUpdated:
            let updatedEffect = effectResponse as! AccountInflationDestinationUpdatedEffectResponse
            createdAt = updatedEffect.createdAt
            type = .inflation
        default:
            break
        }
    }
    
    func getFormatted(amountValue: String) -> String {
        guard let floatValue = Float(amountValue) else {
            return "--"
        }
        
        return String(format: "%.4f", floatValue)
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
        if type == .trade {
            if isBought(asset: asset) {
                return Colors.green
            }
            return Colors.red
        } else {
            return type.color
        }
    }
    
    func formattedDescription(asset: StellarAsset) -> String {
        if type == .trade {
            return "Trade \(soldAsset.shortCode) for \(boughtAsset.shortCode)"
        } else {
            return type.rawValue
        }
    }
    
    func isBought(asset: StellarAsset) -> Bool {
        if asset.assetType == boughtAsset.assetType && asset.assetCode == boughtAsset.assetCode && asset.assetIssuer == boughtAsset.assetIssuer {
            return true
        }
        return false
    }
}
