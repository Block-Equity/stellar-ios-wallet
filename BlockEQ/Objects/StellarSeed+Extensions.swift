//
//  StellarSeed.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension CharacterSet {
    static var base32Alphabet: CharacterSet {
        return CharacterSet(charactersIn: StellarSeed.validCharacters)
    }
}
