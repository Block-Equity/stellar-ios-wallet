//
//  StellarMnemonicPassphrase.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-11-26.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

public struct StellarMnemonicPassphrase {
    static var invalidCharacters: CharacterSet {
        return CharacterSet.alphanumerics.union(CharacterSet.whitespaces).inverted
    }

    public let string: String

    public init?(_ passphrase: String?) {
        guard let phrase = passphrase, !phrase.isEmpty else { return nil }

        guard !StellarMnemonicPassphrase.containsInvalidCharacters(passphrase: phrase) else { return nil }

        guard !StellarMnemonicPassphrase.containsOnlySpacingCharacters(passphrase: phrase) else { return nil }

        string = phrase
    }

    static func containsInvalidCharacters(passphrase: String) -> Bool {
        if passphrase.rangeOfCharacter(from: StellarMnemonicPassphrase.invalidCharacters) != nil {
            return true
        }

        return false
    }

    static func containsOnlySpacingCharacters(passphrase: String) -> Bool {
        if passphrase.rangeOfCharacter(from: CharacterSet.whitespaces.inverted) == nil {
            return true
        }

        return false
    }
}

extension StellarMnemonicPassphrase: Equatable { }
