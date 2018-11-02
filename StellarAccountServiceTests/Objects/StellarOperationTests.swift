//
//  StellarOperationTests.swift
//  StellarAccountServiceTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarAccountService
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
}
