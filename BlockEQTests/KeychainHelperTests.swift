//
//  KeychainHelperTests.swift
//  BlockEQTests
//
//  Created by Nick DiZazzo on 2018-10-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import BlockEQ
import stellarsdk

class KeychainHelperTests: XCTestCase {
    override func setUp() {
        super.setUp()
        KeychainHelper.clearAll()
    }

    override func tearDown() {
        super.tearDown()
        KeychainHelper.clearAll()
    }

    func testKeychainHelperUsesConsistentKeys() {
        XCTAssertEqual(KeychainHelper.pinKey, "pin")
        XCTAssertEqual(KeychainHelper.secretSeedKey, "secretSeed")
        XCTAssertEqual(KeychainHelper.mnemonicKey, "mnemonic")
        XCTAssertEqual(KeychainHelper.accountIdKey, "accountId")
        XCTAssertEqual(KeychainHelper.publicSeedKey, "publicKey")
        XCTAssertEqual(KeychainHelper.privateSeedKey, "privateKey")
        XCTAssertEqual(KeychainHelper.isFreshInstallKey, "isFreshInstall")
    }

    func testKeychainHelperIsProperlyCleared() {
        KeychainHelper.save(pin: "1234")
        KeychainHelper.save(accountId: "G1234")
        KeychainHelper.setExistingInstance()

        XCTAssertEqual(KeychainHelper.pin, "1234")
        XCTAssertEqual(KeychainHelper.accountId, "G1234")
        XCTAssertTrue(KeychainHelper.hasExistingInstance)
        XCTAssertTrue(KeychainHelper.hasPin)

        KeychainHelper.clearAll()

        XCTAssertNil(KeychainHelper.pin)
        XCTAssertNil(KeychainHelper.accountId)
        XCTAssertFalse(KeychainHelper.hasExistingInstance)
        XCTAssertFalse(KeychainHelper.hasPin)
    }

    func testPinCheckPassesWithCorrectPin() {
        KeychainHelper.save(pin: "1234")
        XCTAssertEqual(KeychainHelper.pin, "1234")

        let result = KeychainHelper.check(pin: "1234")
        XCTAssertTrue(result)
    }

    func testPinCheckFailsWithWrongPin() {
        KeychainHelper.save(pin: "1234")
        XCTAssertEqual(KeychainHelper.pin, "1234")

        let result = KeychainHelper.check(pin: "2345")
        XCTAssertFalse(result)
    }

    func testWalletKeyPairFailsWithNoPublicKey() {
        XCTAssertNil(KeychainHelper.publicKey)

        let result = KeychainHelper.walletKeyPair
        XCTAssertNil(result)
    }

    func testWalletKeyPairFailsWithNoPrivateKey() {
        XCTAssertNil(KeychainHelper.privateKey)

        let result = KeychainHelper.walletKeyPair
        XCTAssertNil(result)
    }

//    func testWalletKeyPairReturnsNilIfEitherKeyIsInvalid() {
//        XCTAssertNil(KeychainHelper.publicKey)
//        XCTAssertNil(KeychainHelper.privateKey)
//
//        let invalidKey = String(repeating: "badkey", count: 1000)
//        KeychainHelper.save(publicKey: invalidKey.data(using: .utf8)!)
//        KeychainHelper.save(privateKey: invalidKey.data(using: .utf8)!)
//        XCTAssertNotNil(KeychainHelper.privateKey)
//        XCTAssertNotNil(KeychainHelper.publicKey)
//
//        let result = KeychainHelper.walletKeyPair
//        XCTAssertNil(result)
//    }

//    func testWalletKeyPairReturnsResult() {
//        XCTAssertNil(KeychainHelper.publicKey)
//        XCTAssertNil(KeychainHelper.privateKey)
//
//        let randomKey = try! KeyPair.generateRandomKeyPair()
//        let publicBytes = Data(bytes: randomKey.publicKey.bytes)
//        let privateBytes = Data(bytes: randomKey.privateKey!.bytes)
//
//        KeychainHelper.save(publicKey: publicBytes)
//        KeychainHelper.save(privateKey: privateBytes)
//        XCTAssertNotNil(KeychainHelper.privateKey)
//        XCTAssertNotNil(KeychainHelper.publicKey)
//
//        let result = KeychainHelper.walletKeyPair
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result?.publicKey.bytes, randomKey.publicKey.bytes)
//        XCTAssertEqual(result?.privateKey!.bytes, randomKey.privateKey!.bytes)
//    }

    func testIssuerKeyPairReturnsNilForInvalidAccount() {
        let result = KeychainHelper.issuerKeyPair(accountId: "not good")
        XCTAssertNil(result)
    }

    func testIssuerKeyPairReturnsCorrectResult() {
        let pool = "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"
        let result = KeychainHelper.issuerKeyPair(accountId: pool)
        XCTAssertNotNil(result)
    }
}
