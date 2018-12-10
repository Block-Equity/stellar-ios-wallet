//
//  StellarEffect+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

extension StellarEffect {
    public func getFormatted(amountValue: String) -> String {
        guard let doubleValue = Double(amountValue) else {
            return "--"
        }

        return doubleValue.displayFormattedString
    }

    public func formattedTransactionAmount(asset: StellarAsset) -> String {
        if type == .tradeEffect {
            if isBought(asset: asset) {
                return getFormatted(amountValue: boughtAmount)
            }
            return "(\(getFormatted(amountValue: soldAmount)))"
        } else {
            if type == .accountDebited {
                return "(\(formattedAmount))"
            }
            return formattedAmount
        }
    }

    public func formattedDescription(asset: StellarAsset) -> String {
        if self.type == .tradeEffect {
            return String(format: "TRADE_CURRENCY_PAIR_FORMAT".localized(),
                          assetPair.selling.shortCode,
                          assetPair.buying.shortCode)
        } else {
            return type.title
        }
    }

    public var formattedDate: String {
        let isoDate = createdAt.isoDate
        return isoDate.dateString
    }

    public var formattedAmount: String {
        return getFormatted(amountValue: amount)
    }

    public var color: UIColor {
        return type.color
    }
}

extension EffectType {
    var color: UIColor {
        switch self {
        case .accountCreated: return Colors.primaryDark
        case .accountDebited: return Colors.red
        case .accountCredited: return Colors.green
        case .tradeEffect: return Colors.blueGray
        case .accountInflationDestinationUpdated: return Colors.primaryDark
        default: return Colors.lightGray
        }
    }

    var title: String {
        switch self {
        case .accountCreated: return "Account Created"
        case .accountDebited: return "Sent"
        case .accountCredited: return "Received"
        case .tradeEffect: return "Trade"
        case .accountInflationDestinationUpdated: return "Inflation Set"
        default: return "Unknown"
        }
    }
}
