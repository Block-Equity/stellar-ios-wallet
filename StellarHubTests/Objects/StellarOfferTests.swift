//
//  StellarOfferTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarOfferTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOrderbookOfferInitializer() {
        let response: OrderbookOfferResponse = JSONLoader.decodableJSON(name: "orderbook_offer_response")
        let offer = StellarOrderbookOffer(response)
        XCTAssertEqual(offer.amount, "3.8472400")
        XCTAssertEqual(offer.price, "0.2000000")
        XCTAssertEqual(offer.numerator, 1)
        XCTAssertEqual(offer.denominator, 5)
    }

    func testOrderbookOfferValueReturnsPriceAndAmountMultiplied() {
        let response: OrderbookOfferResponse = JSONLoader.decodableJSON(name: "orderbook_offer_response")
        let offer = StellarOrderbookOffer(response)
        XCTAssertEqual(offer.value.description, "0.769448")
    }

    func testOrderbookOfferValueReturnsZeroIfNotCastable() {
        let response: OrderbookOfferResponse = JSONLoader.decodableJSON(name: "bad_orderbook_offer_response")
        let offer = StellarOrderbookOffer(response)
        XCTAssertEqual(offer.value.description, "0")
    }

    func testAccountOfferInitializerReturnsNilIfBadAmount() {
        let response: OfferResponse = JSONLoader.decodableJSON(name: "bad_amount_offer_response")
        let offer = StellarAccountOffer(response)
        XCTAssertNil(offer)
    }

    func testAccountOfferInitializerReturnsNilIfBadSeller() {
        let response: OfferResponse = JSONLoader.decodableJSON(name: "missing_seller_offer_response")
        let offer = StellarAccountOffer(response)
        XCTAssertNil(offer)
    }

    func testAccountOfferInitializerAssignsCorrectValues() {
        let response: OfferResponse = JSONLoader.decodableJSON(name: "account_offer_response")
        let offer = StellarAccountOffer(response)
        XCTAssertNotNil(offer)

        let issuer = "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S"
        XCTAssertEqual(offer?.buyingAsset, StellarAsset(assetType: "credit_alphanum4",
                                                        assetCode: "CAD",
                                                        assetIssuer: issuer,
                                                        balance: "0.0"))
        XCTAssertEqual(offer?.sellingAsset, StellarAsset.lumens)
        XCTAssertEqual(offer?.identifier, 42514469)
        XCTAssertEqual(offer?.amount, Decimal(string: "1.0000000"))
        XCTAssertEqual(offer?.seller, StellarAddress("GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ"))
        XCTAssertEqual(offer?.numerator, 3)
        XCTAssertEqual(offer?.denominator, 1)
        XCTAssertEqual(offer?.price, "3.0000000")
    }

    func testAccountOfferValueReturnsZeroIfNotCastable() {
        let response: OfferResponse = JSONLoader.decodableJSON(name: "bad_price_offer_response")
        let offer = StellarAccountOffer(response)
        XCTAssertNotNil(offer)
        XCTAssertEqual(offer?.value.description, "0")
    }

    func testAccountOfferValueReturnsPriceAndAmountMultiplied() {
        let response: OfferResponse = JSONLoader.decodableJSON(name: "account_offer_response")
        let offer = StellarAccountOffer(response)
        XCTAssertEqual(offer?.value.description, "3")
    }
}
