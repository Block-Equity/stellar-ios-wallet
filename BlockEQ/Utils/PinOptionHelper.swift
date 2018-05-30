//
//  PinOptionHelper.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class PinOptionHelper {
    enum PinOption: String {
        case pinEnabled = "security-pin-enabled"
        case pinOnLaunch = "security-pin-launch"
        case pinOnTrade = "security-pin-trading"
        case pinOnPayment = "security-pin-payments"
        case pinOnMnemonic = "security-pin-mnemonic"
    }

    static func check(_ option: PinOption) -> Bool {
        return pinSetting(for: .pinEnabled) && pinSetting(for: option)
    }

    static func set(option: PinOption, value: Bool) {
        UserDefaults.standard.set(value, forKey: option.rawValue)
    }

    static func pinSetting(for option: PinOption) -> Bool {
        return UserDefaults.standard.bool(forKey: option.rawValue)
    }

    static func clear() {
        set(option: .pinEnabled, value: true)
        set(option: .pinOnLaunch, value: true)
        set(option: .pinOnTrade, value: true)
        set(option: .pinOnPayment, value: true)
        set(option: .pinOnMnemonic, value: true)
    }
}
