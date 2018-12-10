//
//  StellarSeedTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarSeedTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testValidSeedCharacters() {
        let seedCharacterSet = CharacterSet(charactersIn: StellarSeed.validCharacters)
        let acceptedCharacterSet = CharacterSet(charactersIn: "765432ZYXWVUTSRQPONMLKJIHGFEDCBA")
        XCTAssertEqual(seedCharacterSet, acceptedCharacterSet)
    }

    func testNilSeedInitializerFails() {
        let seed = StellarSeed(nil)
        XCTAssertNil(seed)
    }

    func testEmptySeedFails() {
        let seed = StellarSeed("")
        XCTAssertNil(seed)
    }

    func testInvalidSeedCreationFailes() {
        let seed = StellarSeed("I'm not a valid seed")
        XCTAssertNil(seed)
    }

    func testInitializesWithValidSeed() {
        let seed = StellarSeed(TestHelperData.validSeed)
        XCTAssertNotNil(seed)
    }
}
