//
//  StellarRecoveryMnemonicTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarRecoveryMnemonicTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNilMnemonicFailsInitialization() {
        let mnemonic = StellarRecoveryMnemonic(nil)
        XCTAssertNil(mnemonic)
    }

    func testMneomnicWithTrailingSpaceInitializes() {
        let mnemonic = StellarRecoveryMnemonic(String(repeating: "word ", count: 24))
        XCTAssertNotNil(mnemonic)
    }

    func testValid12WordMnemonic() {
        let mnemonic = StellarRecoveryMnemonic("first second third fourth fifth sixth seventh eigth ninth tenth eleventh twelfth")
        XCTAssertEqual(mnemonic?.words.count, 12)
        XCTAssertNotNil(mnemonic)
    }

    func testValid24WordMnemonic() {
        let mnemonic = StellarRecoveryMnemonic("first second third fourth fifth sixth seventh eigth ninth tenth eleventh twelfth first second third fourth fifth sixth seventh eigth ninth tenth eleventh twelfth")
        XCTAssertEqual(mnemonic?.words.count, 24)
        XCTAssertNotNil(mnemonic)
    }

    func testInvalid2WordMnemonic() {
        let mnemonic = StellarRecoveryMnemonic("not mnemonic")
        XCTAssertNil(mnemonic)
    }

    func testGenerate12ProducesMnemonic() {
        let mnemonic = StellarRecoveryMnemonic.generate(type: .twelve)
        XCTAssertEqual(mnemonic?.words.count, 12)
        XCTAssertNotNil(mnemonic)
    }

    func testGenerate24ProducesMnemonic() {
        let mnemonic = StellarRecoveryMnemonic.generate(type: .twentyFour)
        XCTAssertEqual(mnemonic?.words.count, 24)
        XCTAssertNotNil(mnemonic)
    }
}
