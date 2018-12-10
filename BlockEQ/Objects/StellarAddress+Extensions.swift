//
//  StellarAddress+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-30.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension StellarAddress {
    enum Suffix: String, RawRepresentable {
        case contactAddress = ".publicaddress@blockeq.com"
    }

    static func from(contactAddress: String) -> StellarAddress? {
        let stripped = contactAddress.replacingOccurrences(of: Suffix.contactAddress.rawValue, with: "")
        return StellarAddress(stripped)
    }

    var strippedContactAddress: String {
        return self.string.replacingOccurrences(of: Suffix.contactAddress.rawValue, with: "")
    }

    var contactAddress: String {
        return String(format: "%@%@", self.string, Suffix.contactAddress.rawValue)
    }
}
