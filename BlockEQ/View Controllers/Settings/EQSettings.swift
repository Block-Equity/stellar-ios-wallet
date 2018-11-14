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
        return [walletSection, securitySection, supportSection, aboutSection]
        #else
        return [walletSection, securitySection, supportSection, aboutSection]
        #endif
    }

    static var walletItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_CLEAR_WALLET".localized(),
                             identifier: "wallet-clear",
                             enabled: true,
                             type: .normal),
            keySection
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
//            SettingNode.node(name: "SETTINGS_OPTION_REVIEW".localized(),
//                             identifier: "about-review",
//                             enabled: false,
//                             type: .normal),
//            SettingNode.node(name: "SETTINGS_OPTION_SHARE".localized(),
//                             identifier: "about-share",
//                             enabled: false,
//                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_PRIVACY".localized(),
                             identifier: "about-privacy",
                             enabled: true,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_TERMS".localized(),
                             identifier: "about-terms",
                             enabled: true,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_APPLICATION".localized(),
                             identifier: "about-application",
                             enabled: true,
                             type: .normal)
        ]
    }

    static var keyItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_SEED_PHRASE".localized(),
                             identifier: "keys-view-mnemonic",
                             enabled: true,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_DISPLAY_SECRET_SEED".localized(),
                             identifier: "keys-display-secret-seed",
                             enabled: true,
                             type: .normal),
            SettingNode.node(name: "SETTINGS_OPTION_EXPORT_KEYPAIR".localized(),
                             identifier: "keys-export-private-key",
                             enabled: false,
                             type: .normal)
        ]
    }

    static var supportItems: [SettingNode] {
        return [
            SettingNode.node(name: "SETTINGS_OPTION_DIAGNOSTICS".localized(),
                             identifier: "support-start-diagnostic",
                             enabled: true,
                             type: .normal)
        ]
    }

    static var walletSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_WALLET".localized(),
                                   identifier: "section-wallet",
                                   items: walletItems)
    }

    static var keySection: SettingNode {
        return SettingNode.section(name: "SETTINGS_OPTION_ADV_KEY_MANAGEMENT".localized(),
                                   identifier: "section-keys",
                                   items: keyItems)
    }

    static var pinSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_OPTION_ADV_PASSCODE".localized(),
                                   identifier: "section-security",
                                   items: pinItems)
    }

    static var securitySection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_SECURITY".localized(),
                                   identifier: "section-security",
                                   items: [pinSection])
    }

    static var supportSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_SUPPORT".localized(),
                                   identifier: "section-support",
                                   items: supportItems)
    }

    static var aboutSection: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_ABOUT".localized(),
                                   identifier: "section-about",
                                   items: aboutItems)
    }

    static var debugSettings: SettingNode {
        return SettingNode.section(name: "SETTINGS_SECTION_DEBUG".localized(),
                                   identifier: "section-debug",
                                   items: [])
    }
}
