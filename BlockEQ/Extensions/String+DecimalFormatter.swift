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
        let value = self.doubleValue
        if value > 0 && value <= 0.0001 {
            return "< 0.0001"
        } else {
            return Formatter.displayFormatters.string(for: value) ?? ""
        }
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
        if self > 0 && self <= 0.0001 {
            return "< 0.0001"
        } else {
            return Formatter.displayFormatters.string(for: self) ?? ""
        }
    }
}

extension Double {
    var displayFormattedString: String {
        if self > 0 && self <= 0.0001 {
            return "< 0.0001"
        } else {
            return Formatter.displayFormatters.string(for: self) ?? ""
        }
    }
}
