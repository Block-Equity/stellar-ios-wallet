//
//  StellarTradeOfferData.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-29.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarTradeOfferData {
    public enum TradeType {
        case market
        case limit

        public static let all: [TradeType] = [.market, .limit]
    }

    let type: TradeType
    let assetPair: StellarAssetPair
    let price: Price
    let numerator: Decimal
    let denominator: Decimal
    let offerId: Int?

    public init(type: TradeType,
                assetPair: StellarAssetPair,
                price: Price,
                numerator: Decimal,
                denominator: Decimal,
                offerId: Int? = 0) {
        self.type = type
        self.assetPair = assetPair
        self.price = price
        self.numerator = numerator
        self.denominator = denominator
        self.offerId = offerId
    }

    public init(offerId: Int? = 0, assetPair: StellarAssetPair, price: Price) {
        self.type = .market
        self.assetPair = assetPair
        self.price = price
        self.numerator = Decimal(price.n)
        self.denominator = Decimal(price.d)
        self.offerId = offerId
    }
}
