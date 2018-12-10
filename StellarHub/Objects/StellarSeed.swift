//
//  StellarSeed.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import stellarsdk

public struct StellarSeed {
    public static let validCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    public let string: String

    public init?(_ seed: String?) {
        guard let seed = seed, !seed.isEmpty else { return nil }

        do {
            _ = try Seed(secret: seed)
            self.string = seed
        } catch {
            return nil
        }
    }
}
