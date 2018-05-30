//
//  String+DecimalFormatter.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-29.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

extension String {
    func decimalFormatted() -> String {
        return String(format: "%.4f", self.floatValue())
    }
    
    func floatValue() -> Float {
        guard let floatValue = Float(self) else {
            return 0.00
        }
        return floatValue
    }
}

