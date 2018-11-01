//
//  String+DecimalFormatter.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-29.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

extension Formatter {
    static let minimumDisplayString = "0.0001"
    static let minimumDisplayAmount = Decimal(string: minimumDisplayString)!

    static let displayFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ""
        return formatter
    }()

    static let tradeFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ""
        return formatter
    }()

    static func minimumAmount(with formatter: NumberFormatter, amount: Decimal) -> String {
        if amount > 0 && amount < Formatter.minimumDisplayAmount {
            return String(format: "CRYPTO_DUST_FORMAT_STRING".localized(), minimumDisplayString)
        } else {
            return formatter.string(for: amount) ?? ""
        }
    }
}

extension String {
    var displayFormatted: String {
        return Formatter.minimumAmount(with: Formatter.displayFormatters, amount: self.decimalValue)
    }

    var tradeFormatted: String {
        return Formatter.tradeFormatters.string(for: self.decimalValue) ?? ""
    }

    var decimalValue: Decimal {
        guard let decimal = Decimal(string: self) else {
            return 0.00
        }

        return decimal
    }
}

extension Decimal {
    var displayFormattedString: String {
        return Formatter.minimumAmount(with: Formatter.displayFormatters, amount: self)
    }

    var tradeFormattedString: String {
        return Formatter.tradeFormatters.string(for: self) ?? ""
    }
}

extension Double {
    var displayFormattedString: String {
        return Formatter.minimumAmount(with: Formatter.displayFormatters, amount: Decimal(self))
    }

    var tradeFormattedString: String {
        return Formatter.tradeFormatters.string(for: Decimal(self)) ?? ""
    }
}
