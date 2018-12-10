//
//  StellarOrderbookTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarOrderbookTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatThereAreTwoOrderBookTypes() {
        XCTAssertEqual(StellarOrderbook.OrderBookType.all.count, 2)
    }

    func testThatResponseInitializerSetsCorrectFields() {
        let response: OrderbookResponse = JSONLoader.decodableJSON(name: "orderbook_response")
        let book = StellarOrderbook(response)
        XCTAssertEqual(book.bids.count, 7)
        XCTAssertEqual(book.asks.count, 7)
        XCTAssertEqual(book.pair.selling, StellarAsset.lumens)
        XCTAssertEqual(book.pair.buying, StellarAsset(assetCode: "CAD", issuer: "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S"))
    }

    func testThatBestPriceReturnsNilIfNoBids() {
        let response: OrderbookResponse = JSONLoader.decodableJSON(name: "empty_orderbook_response")
        let book = StellarOrderbook(response)
        XCTAssertNil(book.bestPrice)
    }

    func testThatBestPriceReturnsAmountOfFirstBid() {
        let response: OrderbookResponse = JSONLoader.decodableJSON(name: "orderbook_response")
        let book = StellarOrderbook(response)
        XCTAssertEqual(book.bestPrice, 0.2000000)
    }
}
