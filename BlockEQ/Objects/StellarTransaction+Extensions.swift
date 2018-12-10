//
//  StellarTransaction+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

extension Memo {
    var string: String? {
        switch self {
        case .id(let number): return String(number)
        case .hash(let data): return String(data: data, encoding: .utf8)
        case .returnHash(let data): return String(data: data, encoding: .utf8)
        case .text(let string): return string
        default: return nil
        }
    }
}
