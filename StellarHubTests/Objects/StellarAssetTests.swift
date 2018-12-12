//
//  StellarAssetTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarAssetTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStaticLumenAsset() {
        let lumens = StellarAsset.lumens
        XCTAssertNil(lumens.assetCode)
        XCTAssertNil(lumens.assetIssuer)
        XCTAssertEqual(lumens.assetType, AssetTypeAsString.NATIVE)
        XCTAssertEqual(lumens.balance, "")
    }

    func testShortInitializer() {
        let asset = StellarAsset(assetCode: "PTS", issuer: "G1234")
        XCTAssertEqual(asset.assetCode, "PTS")
        XCTAssertEqual(asset.assetIssuer, "G1234")
    }

    func testAccountBalanceResponseInitializer() {
        let response: AccountBalanceResponse = JSONLoader.decodableJSON(name: "account_balance_response")
        let asset = StellarAsset(response: response)
        XCTAssertTrue(asset.isNative)
        XCTAssertEqual(asset.balance, "100.000000")
        XCTAssertNil(asset.assetCode)
        XCTAssertNil(asset.assetIssuer)
    }

    func testOfferResponseInitializer() {
        let response: OfferAssetResponse = JSONLoader.decodableJSON(name: "offer_asset_response")
        let asset = StellarAsset(response)
        XCTAssertEqual(asset, StellarAsset.lumens)
    }

    func testToRawAssetGeneratesCorrectObject() {
        let address = TestHelperData.lumenautPoolAddress
        let asset = StellarAsset.lumens
        let rawAsset = asset.toRawAsset()
        XCTAssertEqual(rawAsset.type, AssetType.ASSET_TYPE_NATIVE)
        XCTAssertNil(rawAsset.code)
        XCTAssertNil(rawAsset.issuer)

        let asset1 = StellarAsset(assetType: "credit_alphanum4", assetCode: "PTS", assetIssuer: address, balance: "")
        let rawAsset1 = asset1.toRawAsset()
        XCTAssertEqual(rawAsset1.code, "PTS")
        XCTAssertEqual(rawAsset1.type, AssetType.ASSET_TYPE_CREDIT_ALPHANUM4)
        XCTAssertEqual(rawAsset1.issuer?.accountId, address)

        let asset2 = StellarAsset(assetType: "credit_alphanum12", assetCode: "PTS-12345", assetIssuer: address, balance: "")
        let rawAsset2 = asset2.toRawAsset()
        XCTAssertEqual(rawAsset2.code, "PTS-12345")
        XCTAssertEqual(rawAsset2.type, AssetType.ASSET_TYPE_CREDIT_ALPHANUM12)
        XCTAssertEqual(rawAsset2.issuer?.accountId, address)
    }

    func testShortCodeReturnsXLMForNative() {
        XCTAssertEqual(StellarAsset.lumens.shortCode, "XLM")
    }

    func testShortCodeReturnsCodeForNonNative() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: "PTS-12345", assetIssuer: "", balance: "")
        XCTAssertEqual(asset.shortCode, "PTS-12345")
    }

    func testShortCodeReturnsBlankIfNotSet() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: nil, assetIssuer: "", balance: "")
        XCTAssertEqual(asset.shortCode, "")
    }

    func testIsNativeReturnsTrueForXLM() {
        let asset = StellarAsset.lumens
        XCTAssertTrue(asset.isNative)
    }

    func testIsNativeReturnsFalseForNonXLM() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: nil, assetIssuer: "", balance: "")
        XCTAssertFalse(asset.isNative)
    }

    func testNotZeroBalanceIfAssetHasBalance() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: nil, assetIssuer: "", balance: "12.000")
        XCTAssertFalse(asset.hasZeroBalance)
    }

    func testZeroBalanceIfAssetHasNoBalance() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: nil, assetIssuer: "", balance: "")
        XCTAssertTrue(asset.hasZeroBalance)
    }

    func testZeroBalanceIfBalanceIsZeroString() {
        let asset = StellarAsset(assetType: "credit_alphanum12", assetCode: nil, assetIssuer: "", balance: "0.00")
        XCTAssertTrue(asset.hasZeroBalance)
    }

    func testStellarAssetHashesToSameValueIfShortCodeIdentical() {
        let asset = StellarAsset(assetCode: "PTS", issuer: "some issuing address")
        let customNativeAsset = StellarAsset(assetCode: "XLM", issuer: "")
        let nativeAsset = StellarAsset.lumens

        XCTAssertNotEqual(asset.hashValue, nativeAsset.hashValue)
        XCTAssertEqual(customNativeAsset.hashValue, nativeAsset.hashValue)
        XCTAssertNotEqual(nativeAsset, customNativeAsset)
    }
}
