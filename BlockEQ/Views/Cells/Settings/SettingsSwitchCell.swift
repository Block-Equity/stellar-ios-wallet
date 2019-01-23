//
//  SettingsSwitchCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-30.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol SettingsSwitchCellDelegate: AnyObject {
    func toggledSwitch(for node: SettingNode, enabled: Bool)
}

final class SettingsSwitchCell: UITableViewCell, Reusable {
    let switchControl = UISwitch(frame: .zero)

    weak var delegate: SettingsSwitchCellDelegate?

    override var reuseIdentifier: String? { return "SettingsSwitchCell" }
    var settingNode: SettingNode?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        accessoryView = switchControl
        switchControl.onTintColor = Colors.tertiaryDark
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    @objc func switchChanged(switch: UISwitch) {
        guard let node = settingNode else { return }
        delegate?.toggledSwitch(for: node, enabled: `switch`.isOn)
    }
}

extension SettingsSwitchCell: UpdatableCell {
    func update(for node: SettingNode) {
        accessoryType = node.leaf ? .none : .disclosureIndicator
        selectionStyle = .none
        textLabel?.textColor = node.enabled ? .black : .gray
        switchControl.isEnabled = node.enabled
        textLabel?.text = node.name()

        settingNode = node
    }

    func setValue(node: SettingNode, value: String) {
        switchControl.isOn = Bool(value) ?? false
    }
}
