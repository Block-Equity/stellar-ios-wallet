//
//  EQSettings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-25.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

/// The settings that should appear in the settings menu for BlockEQ.
struct EQSettings {
    /// The top level list of options that will appear in the root menu of the settings screen
    let options: [SettingNode]

    /// This initalizer populates options based on the scheme selected. Debug options are only included in debug builds.
    init() {
        #if DEBUG
        options = [walletSection, aboutSection, debugSettings]
        #else
        options = [walletSection, aboutSection]
        #endif
    }

    let walletSection = SettingNode.section(name: "SETTINGS_SECTION_WALLET".localized(), items: [
        SettingNode.node(name: "SETTINGS_OPTION_SEED_PHRASE".localized(), identifier: "wallet-view-seed", enabled: true),
        SettingNode.node(name: "SETTINGS_OPTION_CLEAR_WALLET".localized(), identifier: "wallet-clear", enabled: true)
        ])

    let aboutSection = SettingNode.section(
        name: "SETTINGS_SECTION_COMMUNITY".localized(),
        items: [SettingNode.node(name: "SETTINGS_OPTION_REVIEW".localized(), identifier: "community-review", enabled: false),
                SettingNode.node(name: "SETTINGS_OPTION_SHARE".localized(), identifier: "community-share", enabled: false),
                SettingNode.node(name: "SETTINGS_OPTION_PRIVACY".localized(), identifier: "community-privacy", enabled: false),
                SettingNode.node(name: "SETTINGS_OPTION_TERMS".localized(), identifier: "community-terms", enabled: false),
                SettingNode.node(name: "SETTINGS_OPTION_SUPPORT".localized(), identifier: "community-support", enabled: false)
                ])

    let debugSettings = SettingNode.section(
        name: "SETTINGS_SECTION_DEBUG".localized(),
        items: [SettingNode.node(name: "SETTINGS_OPTION_DISABLE_PIN_CHECK".localized(), identifier: "debug-disable-pin", enabled: true)
        ])
}
