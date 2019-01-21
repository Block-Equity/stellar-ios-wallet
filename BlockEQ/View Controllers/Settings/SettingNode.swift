//
//  SettingsNode.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

/// A recursive enumeration that defines a nested hierarchy of settings to be combined with a SettingsViewController.
///
/// - node: A "leaf" setting, representing an option the user can adjust or change.
/// - subsection: A "parent" that contains a subset of SettingNode objects, which can be subnodes or nodes.
enum SettingNode {
    enum NodeType {
        case normal
        case toggle
        case select
    }

    case node(name: String, identifier: String, enabled: Bool, type: NodeType)
    indirect case section(name: String, identifier: String, items: [SettingNode])

    var count: Int {
        switch self {
        case .section(_, _, let items): return items.count
        default: return 0
        }
    }

    var identifier: String {
        switch self {
        case .node(_, let identifier, _, _): return identifier
        case .section(_, let identifier, _): return identifier
        }
    }

    var name: String? {
        switch self {
        case .node(let nodeName, _, _, _): return nodeName
        case .section(let sectionName, _, _): return sectionName
        }
    }

    var enabled: Bool {
        switch self {
        case .node(_, _, let enabled, _): return enabled
        default: return true
        }
    }

    var leaf: Bool {
        switch self {
        case .node: return true
        default: return false
        }
    }

    var type: NodeType {
        switch self {
        case .node(_, _, _, let type): return type
        default: return .normal
        }
    }

    func name(row: Int? = nil) -> String? {
        switch self {
        case .node(let nodeName, _, _, _): return nodeName
        case .section(let nodeName, _, let items):
            if let row = row {
                return items[row].name()
            } else {
                return nodeName
            }
        }
    }

    func subnode(row: Int) -> SettingNode? {
        switch self {
        case .section(_, _, let items): return items[row]
        default: return nil
        }
    }
}
