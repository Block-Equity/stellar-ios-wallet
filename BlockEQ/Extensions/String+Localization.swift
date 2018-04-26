//
//  String+Localization.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-24.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        let localizationText = NSLocalizedString(self, comment: "")
        guard !localizationText.isEmpty else {
            return self
        }

        return localizationText
    }
}
