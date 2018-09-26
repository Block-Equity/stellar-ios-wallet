//
//  Date+Format.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

extension Date {
    private struct Formatters {
        static let dateFormatter = { () -> DateFormatter in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
           return dateFormatter
        }()
    }

    var dateString: String { return Formatters.dateFormatter.string(from: self) }
}
