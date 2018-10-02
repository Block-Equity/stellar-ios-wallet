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

        let intNumerator = NSDecimalNumber(value: numerator).intValue
        let intDenominator = NSDecimalNumber(value: denominator).intValue
        self.init(numerator: intNumerator, denominator: intDenominator)
    }

    convenience init(numerator: Decimal, denominator: Decimal) {
        let intNumerator = NSDecimalNumber(decimal: numerator).intValue
        let intDenominator = NSDecimalNumber(decimal: denominator).intValue
        self.init(numerator: intNumerator, denominator: intDenominator)
    }

    convenience init(with response: OfferPriceResponse) {
        self.init(numerator: response.numerator, denominator: response.denominator)
    }
}
