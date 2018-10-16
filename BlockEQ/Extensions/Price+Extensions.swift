//
//  Price+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

extension Price {
    enum Error: LocalizedError {
        case amountOverflow
    }

    convenience init(numerator: Double, denominator: Double) throws {
        let doubleMaxInt = Double(Int.max)
        guard numerator <= doubleMaxInt && denominator <= doubleMaxInt else {
            throw Price.Error.amountOverflow
        }

        let int32Numerator = NSDecimalNumber(value: numerator).int32Value
        let int32Denominator = NSDecimalNumber(value: denominator).int32Value
        self.init(numerator: int32Numerator, denominator: int32Denominator)
    }

    convenience init(numerator: Decimal, denominator: Decimal) {
        let int32Numerator = NSDecimalNumber(decimal: numerator).int32Value
        let int32Denominator = NSDecimalNumber(decimal: denominator).int32Value
        self.init(numerator: int32Numerator, denominator: int32Denominator)
    }

    convenience init(numerator: Int, denominator: Int) {
        let int32Numerator = NSDecimalNumber(value: numerator).int32Value
        let int32Denominator = NSDecimalNumber(value: denominator).int32Value
        self.init(numerator: int32Numerator, denominator: int32Denominator)
    }

    convenience init(with response: OfferPriceResponse) {
        self.init(numerator: response.numerator, denominator: response.denominator)
    }
}
