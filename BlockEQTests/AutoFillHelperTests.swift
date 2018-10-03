//
//  AutoFillHelperTests.swift
//  BlockEQTests
//
//  Created by Nick DiZazzo on 2018-10-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import BlockEQ

final class TestAutoFillProvider: AutoFillProvider {
    var calledStore: Bool = false
    var calledRetrieve: Bool = false

    func store(server: CFString, account: CFString, password: CFString?, completion: AutoFillHelper.SaveCallback?) {
        calledStore = true
    }

    func retrieve(server: CFString, account: CFString, completion: @escaping AutoFillHelper.FetchCallback) {
        calledRetrieve = true
    }
}

class AutoFilleHelperTests: XCTestCase {
    override func setUp() {
        super.setUp()
        KeychainHelper.clearAll()
    }

    override func tearDown() {
        KeychainHelper.clearAll()
        super.tearDown()
    }

    func testThatSaveSecretCallsDelegate() {
        let testProvider = TestAutoFillProvider()
        AutoFillHelper.provider = testProvider
        AutoFillHelper.save(secret: "test secret", completion: nil)
        XCTAssertTrue(testProvider.calledStore)
    }

    func testThatSaveMnemonicCallsDelegate() {
        let testProvider = TestAutoFillProvider()
        AutoFillHelper.provider = testProvider
        AutoFillHelper.save(mnemonic: "test mnemonic", completion: nil)
        XCTAssertTrue(testProvider.calledStore)
    }

    func testThatFetchCallsDelegate() {
        let testProvider = TestAutoFillProvider()
        AutoFillHelper.provider = testProvider
        AutoFillHelper.fetch(prefix: nil) { data, error in }
        XCTAssertTrue(testProvider.calledRetrieve)
    }

    func testFormatReturnsCorrectData() {
        let result = AutoFillHelper.formatAutoFillData(prefix: "Prefix -", password: "testPassword")
        XCTAssertEqual(result.server, "blockeq.com" as CFString)
        XCTAssertEqual(result.account, "Prefix - BlockEQ Wallet" as CFString)
        XCTAssertEqual(result.password, "testPassword" as CFString)
    }

    func testFormatReturnsCorrectDataWithNoParameters() {
        let result = AutoFillHelper.formatAutoFillData()
        XCTAssertEqual(result.server, "blockeq.com" as CFString)
        XCTAssertEqual(result.account, "BlockEQ Wallet" as CFString)
        XCTAssertNil(result.password)
    }
}
