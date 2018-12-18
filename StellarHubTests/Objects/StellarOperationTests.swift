//
//  StellarOperationTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarOperationTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializerSetsCorrectFields() {
        let response: OperationResponse = JSONLoader.decodableJSON(name: "operation_response")
        let operation = StellarOperation(response)
        XCTAssertEqual(operation.identifier, "75053501230637057")
        XCTAssertEqual(operation.createdAt, response.createdAt)
        XCTAssertEqual(operation.operationType, OperationType.accountCreated)
    }

    func testPaymentOperationResponseSetsPaymentData() {
        let response: PaymentOperationResponse = JSONLoader.decodableJSON(name: "payment_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.paymentData {
            XCTAssertEqual(data.asset.assetCode, "PTS")
            XCTAssertEqual(data.asset.assetIssuer, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.asset.balance, "123.45")
            XCTAssertEqual(data.destination, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
        }

        XCTAssertNotNil(operation.paymentData)
    }

    func testManageOfferOperationResponseSetsManageData() {
        let response: ManageOfferOperationResponse = JSONLoader.decodableJSON(name: "manage_offer_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.manageData {
            XCTAssertEqual(data.amount, "123.45")
            XCTAssertEqual(data.price, "0.1")
            XCTAssertEqual(data.pair.buying.assetCode, "PTS")
            XCTAssertEqual(data.pair.buying.assetType, "credit_alphanum4")
            XCTAssertEqual(data.pair.buying.assetIssuer, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.pair.selling.assetCode, "CAD")
            XCTAssertEqual(data.pair.buying.assetType, "credit_alphanum4")
            XCTAssertEqual(data.pair.selling.assetIssuer, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.offerId, 12345)
        }

        XCTAssertNotNil(operation.manageData)
    }

    func testAllowTrustResponseSetAllowTrustData() {
        let response: AllowTrustOperationResponse = JSONLoader.decodableJSON(name: "allow_trust_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.allowTrustData {
            XCTAssertEqual(data.asset.assetCode, "PTS")
            XCTAssertEqual(data.asset.assetIssuer, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.asset.assetType, "credit_alphanum4")
            XCTAssertEqual(data.trustor, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.trustee, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")
            XCTAssertTrue(data.allow)
        }

        XCTAssertNotNil(operation.allowTrustData)
    }

    func testChangeTrustResponseSetsChangeTrustData() {
        let response: ChangeTrustOperationResponse = JSONLoader.decodableJSON(name: "change_trust_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.changeTrustData {
            XCTAssertEqual(data.asset.assetCode, "PTS")
            XCTAssertEqual(data.asset.assetIssuer, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.asset.assetType, "credit_alphanum4")
            XCTAssertEqual(data.trustor, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
            XCTAssertEqual(data.trustee, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")

        }

        XCTAssertNotNil(operation.changeTrustData)
    }

    func testSetOptionsResponseSetsOptionsData() {
        let response: SetOptionsOperationResponse = JSONLoader.decodableJSON(name: "set_options_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.optionsData {
            XCTAssertEqual(data.homeDomain, "home")
            XCTAssertEqual(data.inflationDest, "inflation")
            XCTAssertEqual(data.signerKey, "hihihi")
            XCTAssertEqual(data.signerWeight, 100)
        }

        XCTAssertNotNil(operation.optionsData)
    }

    func testAccountCreatedResponseSetsCreateData() {
        let response: AccountCreatedOperationResponse = JSONLoader.decodableJSON(name: "account_created_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.createData {
            XCTAssertEqual(data.account, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")
            XCTAssertEqual(data.balance, 599.3900000)
        }

        XCTAssertNotNil(operation.createData)
    }

    func testMergeResponseSetsMergeData() {
        let response: AccountMergeOperationResponse = JSONLoader.decodableJSON(name: "account_merge_operation_response")
        let operation = StellarOperation(response)

        if let data = operation.mergeData {
            XCTAssertEqual(data.from, "GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")
            XCTAssertEqual(data.into, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
        }

        XCTAssertNotNil(operation.mergeData)
    }

    func testDecodingWorks() {
        let response: OperationResponse = JSONLoader.decodableJSON(name: "operation_response")
        let operation = StellarOperation(response)

        let encoded = try? JSONEncoder().encode(operation)
        XCTAssertNotNil(encoded)
        XCTAssertEqual(encoded?.bytes.count, 141)
    }

    func testEncodingWorks() {
        if let data = JSONLoader.load(jsonFixture: "operation_response") {
            let operation = try? JSONDecoder().decode(StellarOperation.self, from: data)
            XCTAssertNotNil(operation)
        } else {
            XCTFail("Data was unexpectedly nil")
        }
    }
}
