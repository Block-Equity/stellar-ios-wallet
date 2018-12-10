//
//  StellarPaymentDataTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarPaymentDataTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializationSetsCorrectValues() {
        let address = StellarAddress(TestHelperData.lumenautPoolAddress)!
        let data = StellarPaymentData(address: address,
                                      amount: 10,
                                      memo: "test memo",
                                      asset: StellarAsset.lumens)
        XCTAssertEqual(data.address, address)
        XCTAssertEqual(data.amount, 10)
        XCTAssertEqual(data.memo, "test memo")
        XCTAssertEqual(data.asset, StellarAsset.lumens)
    }

    func testDestinationKeyPairHasCorrectAccount() {
        let address = StellarAddress(TestHelperData.lumenautPoolAddress)!
        let data = StellarPaymentData(address: address,
                                      amount: 10,
                                      memo: "test memo",
                                      asset: StellarAsset.lumens)

        XCTAssertNotNil(data.destinationKeyPair)
        XCTAssertEqual(data.destinationKeyPair?.accountId, address.string)
    }
}
