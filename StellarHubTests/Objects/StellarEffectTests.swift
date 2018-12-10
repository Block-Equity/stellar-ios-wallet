//
//  StellarEffectTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
import stellarsdk
@testable import StellarHub

class StellarEffectTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testIsBoughtReturnsTrueForBuyingAsset() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(testResponse)
        let asset = StellarAsset(assetCode: "PTS", issuer: "G1234")
        XCTAssertTrue(effect.isBought(asset: asset))
    }

    func testSetAccountCreatedEffect() {
        let testResponse: AccountCreatedEffectResponse = JSONLoader.decodableJSON(name: "account_created_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.amount, "599.3900000")
    }

    func testSetTradeEffect() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(testResponse)
        let ptsAsset = StellarAsset(assetType: "credit_alphanum4", assetCode: "PTS", assetIssuer: "G1234", balance: "")
        let pair = StellarAssetPair(buying: ptsAsset, selling: StellarAsset.lumens)
        XCTAssertEqual(pair, effect.assetPair)
    }

    func testSetDebitedEffect() {
        let testResponse: AccountDebitedEffectResponse = JSONLoader.decodableJSON(name: "account_debited_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.amount, "123.0000000")
        XCTAssertEqual(effect.asset, StellarAsset.lumens)
    }

    func testSetCreditedEffect() {
        let testResponse: AccountCreditedEffectResponse = JSONLoader.decodableJSON(name: "account_credited_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.amount, "0.1226141")
        XCTAssertEqual(effect.asset, StellarAsset.lumens)
    }

    func testSetInflationEffect() {
        let testResponse: AccountInflationDestinationUpdatedEffectResponse = JSONLoader.decodableJSON(name: "inflation_updated_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.type, .accountInflationDestinationUpdated)
    }

    func testUnhandledTypeInitialization() {
        let testResponse: SignerCreatedEffectResponse = JSONLoader.decodableJSON(name: "signer_created_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.type, .signerCreated)
    }

    func testItComputesCorrectOperationId() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(testResponse)
        XCTAssertEqual(effect.pagingToken, "75053501230637057-1")
        XCTAssertEqual(effect.operationId, "75053501230637057")
    }

    func testIsBoughtReturnsIfEffectRelatesToAssetPair() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(testResponse)

        let comparingAsset = StellarAsset(assetCode: "PTS", issuer: "G1234")
        XCTAssertTrue(effect.isBought(asset: comparingAsset))
    }

    func testOperationCanDecodeAndEncode() {
        let effect: StellarEffect = JSONLoader.decodableJSON(name: "stellar_effect")
        XCTAssertNotNil(effect)
        XCTAssertEqual(effect.type, .accountCreated)
        XCTAssertEqual(effect.identifier, "123")
        XCTAssertEqual(effect.createdAt, "2018-12")
        XCTAssertEqual(effect.pagingToken, "12345-1")

        let encodedBytes = try? JSONEncoder().encode(effect)
        XCTAssertNotNil(encodedBytes)
    }
}
