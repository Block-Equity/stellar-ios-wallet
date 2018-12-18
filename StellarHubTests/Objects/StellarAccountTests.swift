//
//  StellarAccountTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarAccountTests: XCTestCase {
    var stubAccount: StellarAccount!

    override func setUp() {
        super.setUp()
        stubAccount = StellarAccount(accountId: TestHelperData.lumenautPoolAddress)
        stubAccount.inflationDestination = TestHelperData.lumenautPoolAddress
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAccountAddress() {
        XCTAssertEqual(stubAccount.address, StellarAddress("GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"))
    }

    func testInflationAddress() {
        XCTAssertEqual(stubAccount.inflationAddress, StellarAddress("GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"))
    }

    func testIndexedAssetsReturnsCorrectValues() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)

        XCTAssertEqual(account.indexedAssets.count, account.assets.count)
        XCTAssertEqual(account.indexedAssets["XLM"], StellarAsset.lumens)
        XCTAssertEqual(account.indexedAssets["CAD"], StellarAsset(assetCode: "CAD", issuer: "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S"))
        XCTAssertEqual(account.indexedAssets["PTS"], StellarAsset(assetCode: "PTS", issuer: "GBPG7KRYC3PTKHBXQGRD3GMZ5DB4C3D553ZN2ZLH57LBAQIULVY46Z5F"))
    }

    func testResponseInitializer() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)

        XCTAssertEqual(account.accountId, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")
        XCTAssertEqual(account.inflationDestination, "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT")
        XCTAssertEqual(account.totalTrustlines, 2)
        XCTAssertEqual(account.totalSigners, 1)
        XCTAssertEqual(account.totalOffers, 1)
        XCTAssertEqual(account.assets.count, 3)
    }

    func testUpdateWithRawResponse() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        stubAccount.update(withRaw: response)
        XCTAssertEqual(stubAccount.accountId, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")
        XCTAssertEqual(stubAccount.inflationDestination, "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT")
        XCTAssertEqual(stubAccount.totalTrustlines, 2)
        XCTAssertEqual(stubAccount.totalSigners, 1)
        XCTAssertEqual(stubAccount.totalOffers, 1)
        XCTAssertEqual(stubAccount.assets.count, 3)
        XCTAssertFalse(stubAccount.isStub)
    }

    func testBaseReserveCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.baseReserve, 0.5)
    }

    func testTrustlinesCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.trustlines, 1)
    }

    func testOffersCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.offers, 0.5)
    }

    func testSignersCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.signers, 0.5)
    }

    func testEmptyArraysMapped() {
        XCTAssertEqual(stubAccount.transactions.count, 0)
        XCTAssertEqual(stubAccount.effects.count, 0)
        XCTAssertEqual(stubAccount.operations.count, 0)
        XCTAssertEqual(stubAccount.tradeOffers.count, 0)
    }

    func testAccountHash() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)

        let transactionResponse: TransactionResponse = JSONLoader.decodableJSON(name: "transaction_response")
        let effectsResponse: EffectResponse = JSONLoader.decodableJSON(name: "trade_effect")
        let operationResponse: OperationResponse = JSONLoader.decodableJSON(name: "operation_response")

        let transaction = StellarTransaction(transactionResponse)
        let effect = StellarEffect(effectsResponse)
        let operation = StellarOperation(operationResponse)

        account.mappedTransactions = [transaction.identifier: transaction]
        account.mappedEffects = [effect.identifier: effect]
        account.mappedOperations = [operation.identifier: operation]

        XCTAssertEqual(account.hashValue, -1362057893489145949)
    }

    func testAccountEquals() {
        let account1 = StellarAccount(accountId: "hello")
        let account2 = StellarAccount(accountId: "hello")
        let account3 = StellarAccount(accountId: "its me")
        XCTAssertEqual(account1, account2)
        XCTAssertNotEqual(account1, account3)
    }

    func testMinBalanceCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.minBalance, 2.5)
    }

    func testAvailableBalanceCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        let balance = account.availableBalance(for: StellarAsset.lumens)
        XCTAssertEqual(balance.description, "1713.3672173")
    }

    func testAvailableBalanceCalculationReturnsZeroIfNoAssets() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "no_balance_account_response")
        let account = StellarAccount(response)
        let balance = account.availableBalance(for: StellarAsset.lumens)
        XCTAssertEqual(balance.description, "0")
    }

    func testAvailableNativeBalanceReturnsZeroWithNoData() {
        let account = StellarAccount(accountId: "hello")
        XCTAssertEqual(account.availableNativeBalance, 0)
    }

    func testAvailableNativeBalanceReturnsZeroWithManyMinimumBalanceItems() {
        let account = StellarAccount(accountId: "hello")
        account.totalSigners = 2
        account.totalOffers = 4
        account.totalTrustlines = 6
        XCTAssertEqual(account.availableNativeBalance, 0)
    }

    func testAvailableNativeBalanceReturnsNonZeroWithBalanceAndManyMinimumBalanceItems() {
        let account = StellarAccount(accountId: "hello")
        account.assets[0] = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                         assetCode: nil,
                                         assetIssuer: nil,
                                         balance: "1000")
        account.totalSigners = 1
        account.totalOffers = 4
        account.totalTrustlines = 6
        XCTAssertEqual(account.availableNativeBalance, 994)
    }

    func testAvailableBalanceForAssetReturnsZeroIfNoAsset() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4,
                                 assetCode: "NOP",
                                 assetIssuer: nil,
                                 balance: "")
        XCTAssertEqual(account.availableBalance(for: asset), 0)
    }

    func testAssetAvailableBalanceReturnsFullAmountIfNoTradesForNative() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "1000")
        account.assets[0] = asset
        account.totalSigners = 1
        account.totalOffers = 4
        account.totalTrustlines = 6
        XCTAssertEqual(account.availableBalance(for: asset), 994)
    }

    func testAssetAvailableBalanceReturnsAmountWithTradesSubtractedForNative() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "1000")
        account.assets[0] = asset
        account.totalSigners = 1
        account.totalOffers = 1
        account.totalTrustlines = 1
        account.outstandingTradeAmounts[asset] = 900
        XCTAssertEqual(account.availableBalance(for: asset), 98)
    }

    func testAssetAvailableBalanceReturnsFullAmountIfNoTrades() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4, assetCode: "PTS", assetIssuer: nil, balance: "100")
        account.assets[0] = asset
        XCTAssertEqual(account.availableBalance(for: asset), 100)
    }

    func testAssetAvailableBalanceReturnsAmountWithTradesSubtracted() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4, assetCode: "PTS", assetIssuer: nil, balance: "100")
        account.assets[0] = asset
        account.outstandingTradeAmounts[asset] = 90
        XCTAssertEqual(account.availableBalance(for: asset), 10)
    }

    func testAssetAvailableBalanceReturnsZeroIfInvalidBalanceAmount() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4, assetCode: "PTS", assetIssuer: nil, balance: "invalid number")
        account.assets[0] = asset
        XCTAssertEqual(account.availableBalance(for: asset), 0)
    }

    func testAssetAvailableBalanceDoesntSubtractTradesIfParameterProvided() {
        let account = StellarAccount(accountId: "hello")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4, assetCode: "PTS", assetIssuer: nil, balance: "100")
        account.assets[0] = asset
        account.outstandingTradeAmounts[asset] = 90
        XCTAssertEqual(account.availableBalance(for: asset, subtractTradeAmounts: false), 100)
    }
}
