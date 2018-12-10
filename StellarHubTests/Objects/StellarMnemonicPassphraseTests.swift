//
//  StellarMnemonicPassphraseTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-26.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

class StellarMnemonicPassphraseTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMnemonicPassphraseWithSpacesIsValid() {
        let passphrase = StellarMnemonicPassphrase("I have spaces and ascii characters")
        XCTAssertNotNil(passphrase)
    }

    func testBlankMnemonicPassphraseIsInvalid() {
        let passphrase1 = StellarMnemonicPassphrase("")
        let passphrase2 = StellarMnemonicPassphrase(nil)
        XCTAssertNil(passphrase1)
        XCTAssertNil(passphrase2)
    }

    func testLanguagePassphraseCases() {
        let validPhrases = [
            "एक हिंदी वाक्य",
            "日本語文",
            "Una frase en español",
            "한국어 문장",
            "Một câu tiếng việt", "جملة عربية" // right to left on its own line messes with keyboard navigation
        ]

        let phrases = validPhrases.compactMap { StellarMnemonicPassphrase($0) }

        XCTAssertEqual(phrases.count, validPhrases.count)
    }

    func testOnlySpacingPhraseFails() {
        let invalidPhrases = [
            "       ",
            "\t\t\t\t",
            "\t\n      ",
            "       "
        ]

        let phrases = invalidPhrases.compactMap { StellarMnemonicPassphrase($0) }
        XCTAssertEqual(phrases.count, 0)
    }

    func testNonAlphanumericPassphraseIsInvalid() {
        let invalidPhrases = [
            "hypenated-english-phrase",
            "👋🏻",
            "No work {",
            "No work ]",
            "No work ,",
            "No work !",
            "No work $"
        ]

        let phrases = invalidPhrases.compactMap { StellarMnemonicPassphrase($0) }
        XCTAssertEqual(phrases.count, 0)
    }
}
