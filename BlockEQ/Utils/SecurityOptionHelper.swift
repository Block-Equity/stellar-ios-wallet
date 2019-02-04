//
//  SecurityOptionHelper.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class SecurityOptionHelper {
    enum SecurityOption: String {
        case pinEnabled = "security-pin-enabled"
        case pinOnLaunch = "security-pin-launch"
        case pinOnTrade = "security-pin-trading"
        case pinOnPayment = "security-pin-payments"
        case pinOnWallet = "security-pin-mnemonic"
        case useBiometrics = "security-use-biometrics"
    }

    static func check(_ option: SecurityOption) -> Bool {
        return optionSetting(for: .pinEnabled) && optionSetting(for: option)
    }

    static func set(option: SecurityOption, value: Bool) {
        UserDefaults.standard.set(value, forKey: option.rawValue)
    }

    static func optionSetting(for option: SecurityOption) -> Bool {
        return UserDefaults.standard.bool(forKey: option.rawValue)
    }

    static func clear() {
        set(option: .pinEnabled, value: true)
        set(option: .pinOnLaunch, value: true)
        set(option: .pinOnPayment, value: true)
        set(option: .pinOnWallet, value: true)
        set(option: .pinOnTrade, value: false)
        set(option: .useBiometrics, value: false)
    }
}
