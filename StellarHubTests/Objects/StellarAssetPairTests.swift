//
//  StellarAssetPairTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarAssetPairTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializesWithInCorrectOrder() {
        let first = StellarAsset.lumens
        let second = StellarAsset(assetCode: "CAD", issuer: "random string")
        let pair = StellarAssetPair(buying: first, selling: second)
        XCTAssertNotNil(pair)
        XCTAssertEqual(first, pair.buying)
        XCTAssertEqual(second, pair.selling)
    }
}

