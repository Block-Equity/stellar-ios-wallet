//
//  SettingsNormalCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-30.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol UpdatableCell {
    func update(for node: SettingNode)
    func setValue(_ value: String)
}

final class SettingsNormalCell: UITableViewCell, ReusableView {
    override var reuseIdentifier: String? { return "SettingsNormalCell" }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    private func setupCell() {
        selectionStyle = .none
        textLabel?.textColor = .gray
    }
}

extension SettingsNormalCell: UpdatableCell {
    func update(for node: SettingNode) {
        accessoryType = node.leaf ? .none : .disclosureIndicator
        selectionStyle = node.enabled ? .default : .none
        textLabel?.textColor = node.enabled ? .black : .gray
        textLabel?.text = node.name()
    }

    func setValue(_ value: String) {
        // noop
    }
}
