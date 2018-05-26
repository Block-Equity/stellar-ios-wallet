//
//  SettingsViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class UppercasedTableViewHeader: UITableViewHeaderFooterView, ReusableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.text = self.textLabel?.text?.uppercased()
    }
}

/// The SettingsViewController collects and presents a static list of options to the end-user.
final class SettingsViewController: UIViewController {

    private struct Constants {
        static let headerIdentifier = "settings-header"
        static let headerHeight = CGFloat(35)
    }

    /// The table view containing settings options.
    @IBOutlet weak var tableView: UITableView!

    /// The settings to represent and display in this view controller.
    var optionList: [SettingNode]

    /// The object to delegate to when a setting is selected or changed. Automatically passed to new view controllers.
    weak var delegate: SettingsDelegate?

    /// The settings view controller requires a light navigation bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    /// Convenience initializer that provides a settings menu based on a list of hierarchical set of settings nodes.
    ///
    /// - Parameter options: The root of the settings nodes to represent in the contained table view.
    init(options: [SettingNode]) {
        optionList = options
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        optionList = EQSettings().options
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupStyle()
    }

    func setupView() {
        tableView.registerHeader(type: UppercasedTableViewHeader.self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupStyle() {
        title = "Settings".localized()
        
        let closeButton = navigationItem.rightBarButtonItem
        closeButton?.tintColor = .black
    }

    @objc internal func dismissSettings(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let node = optionList[indexPath.section].subnode(row: indexPath.row) else {
            print("ERROR: Missing node for settings item selection at \(indexPath.row)")
            return
        }

        let settingSection = optionList[indexPath.section]
        let settingNode = settingSection.subnode(row: indexPath.row)
        if settingNode?.enabled ?? false {
            self.delegate?.selected(setting: node)
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingSection = optionList[indexPath.section]
        let settingNode = settingSection.subnode(row: indexPath.row)

        let cell = settingSection.cell(for: indexPath.row, tableView: tableView, viewController: self)
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .gray

        // If a setting node returns nil for a subnode - it's a leaf option and doesn't need a disclosure indicator
        if let setting = settingNode, setting.leaf {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        if settingNode?.enabled ?? false {
            cell.selectionStyle = .default
            cell.textLabel?.textColor = .black
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsViewController.Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UppercasedTableViewHeader = tableView.dequeueReusableHeader()
        header.textLabel?.text = optionList[section].name
        return header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return optionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList[section].count
    }
}

extension SettingNode {
    func cell(for row: Int, tableView: UITableView, viewController: UIViewController) -> UITableViewCell {
        var cell: UITableViewCell

        let identifier = self.subnode(row: row)?.identifier

        switch identifier {
        default:
            if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellIdentifier") {
                cell = dequeuedCell
            } else {
                cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCellIdentifier")
            }
            cell.textLabel?.text = self.name(row: row)
        }

        return cell
    }
}
