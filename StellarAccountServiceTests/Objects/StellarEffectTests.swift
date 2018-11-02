//
//  StellarEffectTests.swift
//  StellarAccountServiceTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
import stellarsdk
@testable import StellarAccountService

class StellarEffectTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testIsBoughtReturnsTrueForBuyingAsset() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(response: testResponse)
        let asset = StellarAsset(assetCode: "PTS", issuer: "G1234")
        XCTAssertTrue(effect.isBought(asset: asset))
    }

    func testSetAccountCreatedEffect() {
        let testResponse: AccountCreatedEffectResponse = JSONLoader.decodableJSON(name: "account_created_effect")
        let effect = StellarEffect(response: testResponse)
        XCTAssertEqual(effect.amount, "599.3900000")
    }

    func testSetTradeEffect() {
        let testResponse: TradeEffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let effect = StellarEffect(response: testResponse)
        let ptsAsset = StellarAsset(assetType: "credit_alphanum4", assetCode: "PTS", assetIssuer: "G1234", balance: "")
        let pair = StellarAssetPair(buying: ptsAsset, selling: StellarAsset.lumens)
        XCTAssertEqual(pair, effect.assetPair)
    }

    func testSetDebitedEffect() {
        let testResponse: AccountDebitedEffectResponse = JSONLoader.decodableJSON(name: "account_debited_effect")
        let effect = StellarEffect(response: testResponse)
        XCTAssertEqual(effect.amount, "123.0000000")
        XCTAssertEqual(effect.asset, StellarAsset.lumens)
    }

    func testSetCreditedEffect() {
        let testResponse: AccountCreditedEffectResponse = JSONLoader.decodableJSON(name: "account_credited_effect")
        let effect = StellarEffect(response: testResponse)
        XCTAssertEqual(effect.amount, "0.1226141")
        XCTAssertEqual(effect.asset, StellarAsset.lumens)
    }

    func testSetInflationEffect() {
        let testResponse: AccountInflationDestinationUpdatedEffectResponse = JSONLoader.decodableJSON(name: "inflation_updated_effect")
        let effect = StellarEffect(response: testResponse)
        XCTAssertEqual(effect.type, .accountInflationDestinationUpdated)
    }

    func testUnhandledTypeInitialization() {
        let testResponse: SignerCreatedEffectResponse = JSONLoader.decodableJSON(name: "signer_created_effect")
        let effect = StellarEffect(response: testResponse)
        XCTAssertEqual(effect.type, .signerCreated)
    }
}


