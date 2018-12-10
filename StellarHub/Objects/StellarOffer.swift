//
//  StellarOffer.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarOrderbookOffer {
    public let price: String
    public let amount: String
    public let numerator: Int
    public let denominator: Int

    public var value: Decimal {
        if let priceDecimal = Decimal(string: price), let amountDecimal = Decimal(string: amount) {
            return amountDecimal * priceDecimal
        }

        return Decimal(0)
    }

    internal init(_ response: OrderbookOfferResponse) {
        self.price = response.price
        self.amount = response.amount
        self.numerator = response.priceR.numerator
        self.denominator = response.priceR.denominator
    }
}

public struct StellarAccountOffer {
    public let identifier: Int
    public let amount: Decimal
    public let price: String
    public let seller: StellarAddress
    public let sellingAsset: StellarAsset
    public let buyingAsset: StellarAsset
    public let numerator: Int
    public let denominator: Int

    public var value: Decimal {
        if let priceDecimal = Decimal(string: price) {
            return amount * priceDecimal
        }

        return Decimal(0)
    }

    public init?(_ response: OfferResponse) {
        guard let amount = Decimal(string: response.amount) else { return nil }
        guard let address = StellarAddress(response.seller) else { return nil }

        self.buyingAsset = StellarAsset(response.buying)
        self.sellingAsset = StellarAsset(response.selling)
        self.identifier = response.id
        self.amount = amount
        self.seller = address
        self.numerator = response.priceR.numerator
        self.denominator = response.priceR.denominator
        self.price = response.price
    }
}

extension StellarAccountOffer: Equatable { }
extension StellarOrderbookOffer: Equatable { }
