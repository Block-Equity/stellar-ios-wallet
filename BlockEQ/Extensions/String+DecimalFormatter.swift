//
//  String+DecimalFormatter.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-29.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

extension Formatter {
    static let displayFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ""
        return formatter
    }()
}

extension String {
    var decimalFormatted: String {
        return Formatter.displayFormatters.string(for: self.doubleValue) ?? ""
    }

    var doubleValue: Double {
        guard let double = Double(self) else {
            return 0.00
        }

        return double
    }
}

extension Decimal {
    var displayFormattedString: String {
        return Formatter.displayFormatters.string(for: self) ?? ""
    }
}

extension Double {
    var displayFormattedString: String {
        return Formatter.displayFormatters.string(for: self) ?? ""
    }
}
