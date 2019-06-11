//
//  Data+Extensions.swift
//  StellarHub
//
//  Created by Ocean Cheung on 2019-06-11.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Foundation

extension Data {

    internal init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }

    internal var bytes: Array<UInt8> {
        return Array(self)
    }

    internal func toHexString() -> String {
        return bytes.toHexString()
    }
}

extension Array {
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }

    var slice: ArraySlice<Element> {
        return self[self.startIndex..<self.endIndex]
    }
}
