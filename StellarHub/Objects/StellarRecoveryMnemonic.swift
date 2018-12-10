//
//  StellarMnemonic.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarRecoveryMnemonic {
    public enum MnemonicType {
        case twelve
        case twentyFour
    }

    public let type: MnemonicType
    public let string: String
    public let words: [String]

    public init?(_ string: String?) {
        guard let string = string else { return nil }

        self.string = string.last == " " ? String(string.dropLast()) : string
        self.words = string
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        if words.count == 24 {
            type = .twentyFour
        } else if words.count == 12 {
            type = .twelve
        } else {
            return nil
        }
    }

    public static func generate(type: MnemonicType) -> StellarRecoveryMnemonic? {
        let mnemonicString: String

        switch type {
        case .twelve: mnemonicString = Wallet.generate12WordMnemonic()
        case .twentyFour: mnemonicString = Wallet.generate24WordMnemonic()
        }

        return StellarRecoveryMnemonic(mnemonicString)
    }
}
