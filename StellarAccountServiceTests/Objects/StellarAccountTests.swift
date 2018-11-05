//
//  StellarAccountTests.swift
//  StellarAccountServiceTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarAccountService
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

    func testThatUpdateOptionsCanBeInitialized() {
        let options = StellarAccount.UpdateOptions(rawValue: 2)
        XCTAssertEqual(options, .account)
    }

    func testAccountQueueHasHighPriority() {
        XCTAssertEqual(stubAccount.accountQueue.qualityOfService, .userInitiated)
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

    func testMinBalanceCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.minBalance, 2.5)
    }

    func testAvailableBalanceCalculation() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.availableBalance.description, "1713.3672173")
    }

    func testAvailableBalanceCalculationReturnsZeroIfNoAssets() {
        let response: AccountResponse = JSONLoader.decodableJSON(name: "no_balance_account_response")
        let account = StellarAccount(response)
        XCTAssertEqual(account.availableBalance.description, "0")
    }

    func testEmptyArraysMapped() {
        XCTAssertEqual(stubAccount.transactions.count, 0)
        XCTAssertEqual(stubAccount.effects.count, 0)
        XCTAssertEqual(stubAccount.operations.count, 0)
        XCTAssertEqual(stubAccount.tradeOffers.count, 0)
    }
}
