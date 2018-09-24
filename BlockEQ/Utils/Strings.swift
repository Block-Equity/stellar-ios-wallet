//
//  Strings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-25.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

enum DeviceString {
    case biometicType

    var value: String {
        switch self {
        case .biometicType:
            return UIDevice.current.iPhoneX ?
                "SETTINGS_OPTION_USE_FACEID".localized() : "SETTINGS_OPTION_USE_TOUCHID".localized()
        }
    }
}
