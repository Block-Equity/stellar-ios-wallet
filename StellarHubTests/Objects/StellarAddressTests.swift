//
//  StellarAddressTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarAddressTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testValidAddressDoesntFail() {
        let address = StellarAddress(TestHelperData.lumenautPoolAddress)
        XCTAssertNotNil(address)
    }

    func testNilAddressFails() {
        let address = StellarAddress(nil)
        XCTAssertNil(address)
    }

    func testInitializerFailsIfIncorrectAddressPrefix() {
        let address = StellarAddress("S12345")
        XCTAssertNil(address)
    }

    func testInitializerFailsIfIncorrectAddressLength() {
        let address = StellarAddress("G12345")
        XCTAssertNil(address)
    }

    func testKindReturnsNormal() {
        let address = StellarAddress(TestHelperData.lumenautPoolAddress)
        XCTAssertEqual(address?.kind, .normal)
    }
}
