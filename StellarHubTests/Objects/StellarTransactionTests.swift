//
//  StellarTransactionTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class StellarTransactionTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializer() {
        let response: TransactionResponse = JSONLoader.decodableJSON(name: "transaction_response")
        let transaction = StellarTransaction(response)
        XCTAssertEqual(transaction.sourceAccount, "GCO2IP3MJNUOKS4PUDI4C7LGGMQDJGXG3COYX3WSB4HHNAHKYV5YL3VC")
        XCTAssertEqual(transaction.identifier, "82b5d7c4c8dd9884160a6a7bf5516d0abeb18b568552f6656e8eceb672436474")
        XCTAssertEqual(transaction.ledger, 17474755)
        XCTAssertEqual(transaction.createdAt, response.createdAt)
        XCTAssertEqual(transaction.feePaid, 100)
        XCTAssertEqual(transaction.memo, Memo.none)
        XCTAssertEqual(transaction.memoType, "none")
        XCTAssertEqual(transaction.operationCount, 1)
        XCTAssertEqual(transaction.sequenceNumber, "64034663848741309")
        XCTAssertEqual(transaction.signatures, [
            "aBJG0AWQzrqyiC/7J7XB1xabzVWi64J2cb9MNjkAMwTE6Agh3VDWLiO/Dxo9IkMIz4EFxt+ZfkepheXdbz28Cg=="
            ])
    }

    func testEncodingWorks() {
        let response: TransactionResponse = JSONLoader.decodableJSON(name: "transaction_response")
        let transaction = StellarTransaction(response)

        let encoded = try? JSONEncoder().encode(transaction)
        XCTAssertNotNil(encoded)
        XCTAssertEqual(encoded?.bytes.count, 472)
    }

    func testDecodingWorks() {
        if let data = JSONLoader.load(jsonFixture: "transaction_response") {
            let transaction = try? JSONDecoder().decode(StellarTransaction.self, from: data)
            XCTAssertNotNil(transaction)
        } else {
            XCTFail("Data was unexpectedly nil")
        }
    }
}
