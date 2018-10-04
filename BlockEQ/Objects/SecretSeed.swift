//
//  SecretSeed.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-04.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import stellarsdk

extension CharacterSet {
    static var base32Alphabet: CharacterSet {
        return CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
    }
}

final class SecretSeed {
    let string: String

    init?(_ seed: String?) {
        guard let seed = seed, !seed.isEmpty else { return nil }

        do {
            _ = try Seed(secret: seed)
            self.string = seed
        } catch {
            return nil
        }
    }
}
