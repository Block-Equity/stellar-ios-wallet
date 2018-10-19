//
//  String+Date.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

extension String {
    private struct Formatters {
        static let dateFormatter = { () -> ISO8601DateFormatter in
            return ISO8601DateFormatter()
        }()
    }

    var isoDate: Date {
        if let date = Formatters.dateFormatter.date(from: self) {
            return date
        }

        return Date()
    }
}
