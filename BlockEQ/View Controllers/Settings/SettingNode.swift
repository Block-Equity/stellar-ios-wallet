//
//  SettingsNode.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-24.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

/// A recursive enumeration that defines a nested hierarchy of settings to be combined with a SettingsViewController.
///
/// - node: A "leaf" setting, representing an option the user can adjust or change.
/// - subsection: A "parent" that contains a subset of SettingNode objects, which can be subnodes or nodes.
enum SettingNode {
    case node(name: String, identifier: String, enabled: Bool)
    indirect case section(name: String, items: [SettingNode])

    var count: Int {
        switch self {
        case .section(_, let items): return items.count
        default: return 0
        }
    }

    var identifier: String {
        switch self {
        case .node(_, let identifier, _): return identifier
        case .section: return "UNSPECIFIED".localized()
        }
    }

    var name: String? {
        switch self {
        case .node(let nodeName, _, _): return nodeName
        case .section(let sectionName, _): return sectionName
        }
    }

    var enabled: Bool {
        switch self {
        case .node(_, _, let enabled): return enabled
        default: return true
        }
    }

    var leaf: Bool {
        switch self {
        case .node(_, _, _): return true
        default: return false
        }
    }

    func name(row: Int? = nil) -> String? {
        switch self {
        case .node(let nodeName, _, _): return nodeName
        case .section(let nodeName, let items):
            if let row = row {
                return items[row].name()
            } else {
                return nodeName
            }
        }
    }

    func subnode(row: Int) -> SettingNode? {
        switch self {
        case .section(_, let items): return items[row]
        default: return nil
        }
    }
}
