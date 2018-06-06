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
    var boughtamount = ""
    var date: String = ""
    var asset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var soldAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var boughtAsset: StellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    var type: StellarEffectType = .accountCreated
    
    init(effect: EffectResponse) {
        switch effect.effectType {
        case .accountCreated:
            let updatedEffect = effect as! AccountCreatedEffectResponse
            amount = updatedEffect.startingBalance
            date = updatedEffect.createdAt
        case .accountDebited:
            let updatedEffect = effect as! AccountDebitedEffectResponse
            amount = updatedEffect.amount
            date = updatedEffect.createdAt
            asset = StellarAsset(assetType: updatedEffect.assetType, assetCode: updatedEffect.assetCode, assetIssuer:updatedEffect.assetIssuer, balance: "")
            type = .sent
        case .accountCredited:
            let updatedEffect = effect as! AccountCreditedEffectResponse
            amount = updatedEffect.amount
            date = updatedEffect.createdAt
            asset = StellarAsset(assetType: updatedEffect.assetType, assetCode: updatedEffect.assetCode, assetIssuer:updatedEffect.assetIssuer, balance: "")
            type = .received
        case .tradeEffect:
            let updatedEffect = effect as! TradeEffectResponse
            soldAsset = StellarAsset(assetType: updatedEffect.soldAssetType, assetCode: updatedEffect.soldAssetCode, assetIssuer:updatedEffect.soldAssetIssuer, balance: "")
            boughtAsset = StellarAsset(assetType: updatedEffect.boughtAssetType, assetCode: updatedEffect.boughtAssetCode, assetIssuer:updatedEffect.boughtAssetIssuer, balance: "")
            boughtamount = updatedEffect.boughtAmount
            soldAmount = updatedEffect.soldAmount
            date = updatedEffect.createdAt
            type = .trade
        case .accountInflationDestinationUpdated:
            let updatedEffect = effect as! AccountInflationDestinationUpdatedEffectResponse
            date = updatedEffect.createdAt
            type = .inflation
        default:
            break
        }
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let dateString: String = dateFormatter.string(from: Date())
        
        return dateString
    }
    
    var formattedAmount: String {
        guard let floatValue = Float(amount) else {
            return "--"
        }
        
        return String(format: "%.4f", floatValue)
    }
}
