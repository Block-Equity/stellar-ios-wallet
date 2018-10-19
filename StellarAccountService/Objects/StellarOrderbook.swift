//
//  StellarOrderbook.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarOrderbook {
    public enum OrderBookType: Int {
        case bid
        case ask

        public static var all: [OrderBookType] {
            return [.bid, .ask]
        }
    }

    public let bids: [StellarOrderbookOffer]
    public let asks: [StellarOrderbookOffer]
    public let pair: StellarAssetPair

    public init(pair: StellarAssetPair, bids: [StellarOrderbookOffer], asks: [StellarOrderbookOffer]) {
        self.bids = bids
        self.asks = asks
        self.pair = pair
    }

    public init(response: OrderbookResponse) {
        self.pair = StellarAssetPair(buying: StellarAsset(response.buying),
                                     selling: StellarAsset(response.selling))

        self.asks = response.asks.map { StellarOrderbookOffer($0) }
        self.bids = response.bids.map { StellarOrderbookOffer($0) }
    }
}

extension StellarOrderbook {
    public var bestPrice: Double? {
        guard bids.count > 0 else { return nil }
        return Double(bids[0].price)
    }
}

extension StellarOrderbook: Equatable { }
