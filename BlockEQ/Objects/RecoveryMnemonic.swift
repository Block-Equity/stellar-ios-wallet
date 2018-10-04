//
//  RecoveryMnemonic.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-04.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

final class RecoveryMnemonic {
    enum MnemonicType {
        case twelve
        case twentyFour
    }

    let type: MnemonicType
    let string: String
    let words: [String]

    init?(_ string: String?) {
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
}
