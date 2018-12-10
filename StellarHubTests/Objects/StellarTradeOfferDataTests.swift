//
//  StellarTradeOfferDataTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarTradeOfferDataTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFullInitializerSetsCorrectFields() {
        let pair = StellarAssetPair(buying: StellarAsset.lumens, selling: StellarAsset.lumens)
        let price = Price(numerator: 2, denominator: 1)
        let data = StellarTradeOfferData(type: .market, assetPair: pair, price: price, numerator: Decimal(2), denominator: Decimal(1), offerId: 2)

        XCTAssertEqual(data.type, .market)
        XCTAssertEqual(data.assetPair, pair)
        XCTAssertEqual(data.price, price)
        XCTAssertEqual(data.numerator, Decimal(2))
        XCTAssertEqual(data.denominator, Decimal(1))
        XCTAssertEqual(data.offerId, 2)
    }

    func testPartialInitializerSetsCorrectFields() {
        let pair = StellarAssetPair(buying: StellarAsset.lumens, selling: StellarAsset.lumens)
        let price = Price(numerator: 2, denominator: 1)
        let data = StellarTradeOfferData(offerId: 2, assetPair: pair, price: price)
        XCTAssertEqual(data.assetPair, pair)
        XCTAssertEqual(data.price, price)
        XCTAssertEqual(data.offerId, 2)
    }
}
