//
//  Strings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-25.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

enum DeviceString {
    case application
    case biometicType

    var value: String {
        switch self {
        case .biometicType:
            return UIDevice.current.iPhoneX ?
                "SETTINGS_OPTION_USE_FACEID".localized() : "SETTINGS_OPTION_USE_TOUCHID".localized()
        case .application:
            if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String,
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
                return String(format: "%@\nVersion: %@ (%@)", appName, appVersion, bundleVersion)
            } else {
                return ""
            }
        }
    }
}
