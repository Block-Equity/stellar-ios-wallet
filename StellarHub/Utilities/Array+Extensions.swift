//
//  Array+Extensions.swift
//  StellarHub
//
//  Created by Ocean Cheung on 2019-06-11.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Foundation

//swiftlint:disable identifier_name
extension Array {

    /// split in chunks with given chunk size
    @available(*, deprecated: 0.8.0, message: "")
    public func chunks(size chunksize: Int) -> Array<Array<Element>> {
        var words = Array<Array<Element>>()
        words.reserveCapacity(count / chunksize)
        for idx in stride(from: chunksize, through: count, by: chunksize) {
            words.append(Array(self[idx - chunksize..<idx])) // slow for large table
        }
        let remainder = suffix(count % chunksize)
        if !remainder.isEmpty {
            words.append(Array(remainder))
        }
        return words
    }
}

internal extension Array where Element == UInt8 {

    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }

            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }

    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
}
//swiftlint:enable identifier_name
