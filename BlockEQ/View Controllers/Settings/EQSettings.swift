//
//  EQSettings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

/// The settings that should appear in the settings menu for BlockEQ.
struct EQSettings {
    /// This initalizer populates options based on the scheme selected. Debug options are only included in debug builds.
    static var options: [SettingNode] {
        #if DEBUG
        return [recoverySection, walletSection, securitySection]
        #else
        return [recoverySection, walletSection, securitySection]
        #endif
    }

    static var recoveryItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_SEED_PHRASE".localized(),
                             identifier: "wallet-view-seed",
                             enabled: true,
                             type: .normal)
        ]
    }

    static var walletItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_CLEAR_WALLET".localized(),
                             identifier: "wallet-clear",
                             enabled: true,
                             type: .normal)
        ]
    }

    static var pinItems: [SettingNode] {
        return [
            SettingNode.node(name: DeviceString.biometicType.value,
                             identifier: "security-use-biometrics",
                             enabled: AuthenticationCoordinator.biometricsAvailable,
                             type: .toggle),
            SettingNode.node(name: "SETTINGS_OPTION_PIN_LAUNCH".localized(),
                             identifier: "security-pin-launch",
                             enabled: true,
                             type: .toggle),
            SettingNode.node(name: "SETTINGS_OPTION_PIN_PAYMENTS".localized(),
                             identifier: "security-pin-payments",
                             enabled: true,
                             type: .toggle),
            SettingNode.node(name: "SETTINGS_OPTION_PIN_MNEMONIC".localized(),
                             identifier: "security-pin-mnemonic",
                             enabled: false,
                             type: .toggle)
        ]
    }

    static var aboutItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_REVIEW".localized(),
                             identifier: "community-review",
                             enabled: false,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_SHARE".localized(),
                             identifier: "community-share",
                             enabled: false,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_PRIVACY".localized(),
                             identifier: "community-privacy",
                             enabled: false,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_TERMS".localized(),
                             identifier: "community-terms",
                             enabled: false,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_SUPPORT".localized(),
                             identifier: "community-support",
                             enabled: false,
                             type: .normal)
        ]
    }

    static var recoverySection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_RECOVERY".localized(),
                                   identifier: "section-recovery",
                                   items: recoveryItems)
    }

    static var walletSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_WALLET".localized(),
                                   identifier: "section-wallet",
                                   items: walletItems)
    }

    static var pinSection: SettingNode {
        return SettingNode.section(name: "SETTINS_OPTION_ADV_PASSCODE".localized(),
                                   identifier: "section-security",
                                   items: pinItems)
    }

    static var securitySection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_SECURITY".localized(),
                                   identifier: "section-security",
                                   items: [pinSection])
    }

    static var aboutSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_COMMUNITY".localized(),
                                   identifier: "section-about",
                                   items: aboutItems)
    }

    static var debugSettings: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_DEBUG".localized(),
                                   identifier: "section-debug",
                                   items: [])
    }
}
