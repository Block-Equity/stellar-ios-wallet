//
//  SettingsDelegate.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol SettingsDelegate: AnyObject {
    func selected(setting: SettingNode, value: String?)
    func value(for setting: SettingNode) -> String
}
