//
//  SettingsViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class UppercasedTableViewHeader: UITableViewHeaderFooterView, Reusable {
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.text = self.textLabel?.text?.uppercased()
    }
}

/// The SettingsViewController collects and presents a static list of options to the end-user.
final class SettingsViewController: UIViewController {

    internal struct Constants {
        static let headerIdentifier = "settings-header"
        static let headerHeight = CGFloat(35)
    }

    /// The table view containing settings options.
    @IBOutlet var tableView: UITableView!

    /// The settings to represent and display in this view controller.
    var optionList: [SettingNode]

    /// The object to delegate to when a setting is selected or changed. Automatically passed to new view controllers.
    weak var delegate: SettingsDelegate?

    /// The settings view controller requires a light navigation bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    /// Convenience initializer that provides a settings menu based on a list of hierarchical set of settings nodes.
    ///
    /// - Parameter options: The root of the settings nodes to represent in the contained table view.
    init(options: [SettingNode], customTitle: String? = nil) {
        optionList = options
        super.init(nibName: nil, bundle: nil)
        title = customTitle?.localized() ?? ""
    }

    required init?(coder aDecoder: NSCoder) {
        optionList = EQSettings.options
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    func setupView() {
        tableView.register(headerFooterViewType: UppercasedTableViewHeader.self)
        tableView.register(cellType: SettingsNormalCell.self)
        tableView.register(cellType: SettingsSwitchCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupStyle() {
        let closeButton = navigationItem.rightBarButtonItem
        closeButton?.tintColor = .black
    }

    func clearCellAccessories() {
        for index in 0...tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
        }
    }

    @objc internal func dismissSettings(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let settingSection = optionList[indexPath.section]
        guard let settingNode = settingSection.subnode(row: indexPath.row) else {
            print("ERROR: Missing node for settings item selection at \(indexPath.row)")
            return
        }

        if settingNode.enabled && settingNode.type == .normal {
            self.delegate?.selected(setting: settingNode, value: nil)
        } else if settingNode.enabled && settingNode.type == .select {
            self.delegate?.selected(setting: settingNode, value: nil)

            clearCellAccessories()
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingSection = optionList[indexPath.section]
        let settingNode = settingSection.subnode(row: indexPath.row)
        let cell = settingSection.cell(for: indexPath, tableView: tableView, viewController: self)

        if let setting = settingNode, let settingCell = cell as? UpdatableCell {
            settingCell.update(for: setting)

            if let cellValue = delegate?.value(for: setting) {
                settingCell.setValue(node: setting, value: cellValue)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsViewController.Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UppercasedTableViewHeader? = tableView.dequeueReusableHeaderFooterView()
        header?.textLabel?.text = optionList[section].name
        return header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return optionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList[section].count
    }
}

extension SettingsViewController: SettingsSwitchCellDelegate {
    func toggledSwitch(for node: SettingNode, enabled: Bool) {
        delegate?.selected(setting: node, value: String(enabled))
    }
}

extension SettingNode {
    func cell(for indexPath: IndexPath,
              tableView: UITableView,
              viewController: SettingsViewController) -> UITableViewCell {
        var cell: UITableViewCell!

        if let setting = self.subnode(row: indexPath.row) {
            switch setting.type {
            case .normal:
                let normalCell: SettingsNormalCell = tableView.dequeueReusableCell(for: indexPath)
                cell = normalCell
            case .toggle:
                let switchCell: SettingsSwitchCell = tableView.dequeueReusableCell(for: indexPath)
                switchCell.delegate = viewController
                cell = switchCell
            case .select:
                let selectCell: SettingsNormalCell = tableView.dequeueReusableCell(for: indexPath)
//                selectCell.delegate = viewController
                cell = selectCell
            }
        }

        return cell
    }
}
