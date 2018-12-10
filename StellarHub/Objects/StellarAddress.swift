//
//  StellarAddress.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

public struct StellarAddress {
    public enum AddressType {
        case normal
        case federated
    }

    public let string: String

    public var kind: AddressType {
        return .normal
    }

    public init?(_ accountId: String?) {
        guard let uppercasedId = accountId?.uppercased() else { return nil }
        guard uppercasedId.prefix(1) == "G" else { return nil }
        guard uppercasedId.count == 56 else { return nil }
        self.string = uppercasedId
    }
}

extension StellarAddress: Equatable { }
