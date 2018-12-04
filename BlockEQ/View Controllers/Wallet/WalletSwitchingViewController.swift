//
//  WalletSwitchingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

protocol WalletSwitchingViewControllerDelegate: class {
    func reloadAssets()

    func switchWallet(to asset: StellarAsset)
    func selectedAddAsset()

    func createTrustLine(to address: StellarAddress, for asset: StellarAsset)
    func updateInflation()
    func remove(asset: StellarAsset)
    func add(asset: StellarAsset)
}

final class WalletSwitchingViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderTitleLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    weak var delegate: WalletSwitchingViewControllerDelegate?
    var dataSource: WalletSwitchingDataSource?
    var isAddingAsset: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView?.dataSource = dataSource
        tableView?.reloadData()

        hideHud()
    }

    func setupView() {
        addNavigationHeader()

        tableViewHeader.backgroundColor = Colors.lightBackground
        tableViewHeaderTitleLabel.textColor = Colors.darkGray

        tableView?.delegate = self
        tableView.registerCell(type: WalletItemCell.self)
        tableView.registerCell(type: WalletItemActivateCell.self)
    }

    func addNavigationHeader() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ASSETS".localized()
    }

    func updateMenu(account: StellarAccount) {
        rebuildDataSource(using: account)
        tableView?.reloadData()

        hideHud()
    }

    func rebuildDataSource(using account: StellarAccount) {
        let dataSource = WalletSwitchingDataSource(account: account)
        dataSource.delegate = self

        self.dataSource = dataSource

        tableView?.dataSource = dataSource
    }

    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = message
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func displayAssetActivationError(_ error: FrameworkError) {
        let fallbackTitle = "ACTIVATION_ERROR_TITLE".localized()
        let fallbackMessage = "ASSET_BALANCE_ERROR_MESSAGE".localized()
        self.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }

    func displayAssetDeactivationError(_ error: FrameworkError) {
        let fallbackTitle = "ACTIVATION_ERROR_TITLE".localized()
        let fallbackMessage = "ASSET_REMOVE_ERROR_MESSAGE".localized()
        self.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }

    func displayNoBalanceError() {
        let alert = UIAlertController(title: "NO_BALANCE_ERROR_TITLE".localized(),
                                      message: "LOW_BALANCE_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func selectedAddAsset() {
        if let dataSource = dataSource, dataSource.isZeroBalance() {
            displayNoBalanceError()
        } else {
            delegate?.selectedAddAsset()
        }
    }

    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    func displayRemovePrompt() {
        showHud(message: "REMOVING_ASSET".localized())
        self.isAddingAsset = false
    }

    func displayAddPrompt() {
        showHud(message: "ACTIVATING_ASSET".localized())
        self.isAddingAsset = true
    }
}

extension WalletSwitchingViewController: AccountUpdatable {
    func updated(account: StellarAccount) {
        rebuildDataSource(using: account)
        tableView?.reloadData()

        hideHud()
    }
}

extension WalletSwitchingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = WalletSwitchingDataSource.Section(rawValue: section),
            let dataSource = self.dataSource else { return nil }

        switch section {
        case .userAssets: return nil
        default: return dataSource.hasSupportedAssets ? tableViewHeader : nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = WalletSwitchingDataSource.Section(rawValue: section),
            let dataSource = self.dataSource else { return 0 }

        switch section {
        case .userAssets: return 0
        default: return dataSource.hasSupportedAssets ? tableViewHeader.frame.size.height : 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = WalletSwitchingDataSource.Section(rawValue: indexPath.section) else { return 0 }
        return section.sectionRowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let section = WalletSwitchingDataSource.Section(rawValue: indexPath.section),
            section == .userAssets, let asset = dataSource?.allAssets[indexPath.row] else {
                return
        }

        switch section {
        case WalletSwitchingDataSource.Section.userAssets:
            delegate?.switchWallet(to: asset)
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

extension WalletSwitchingViewController: WalletDataSourceDelegate {
    func createTrustLine(_ dataSource: WalletSwitchingDataSource, to address: StellarAddress, asset: StellarAsset) {
        delegate?.createTrustLine(to: address, for: asset)
    }

    func remove(_ dataSource: WalletSwitchingDataSource, asset: StellarAsset) {
        displayRemovePrompt()

        if let nativeAsset = dataSource.allAssets.first {
            delegate?.switchWallet(to: nativeAsset)
        }

        delegate?.remove(asset: asset)
    }

    func add(_ dataSource: WalletSwitchingDataSource, asset: StellarAsset) {
        displayAddPrompt()
        delegate?.add(asset: asset)
    }

    func updateInflation(_ dataSource: WalletSwitchingDataSource) {
        if dataSource.isZeroBalance() {
            displayNoBalanceError()
        } else {
            delegate?.updateInflation()
        }
    }
}

extension WalletSwitchingViewController: ManageAssetResponseDelegate {
    func added(asset: StellarAsset, account: StellarAccount) {
        self.hideHud()
        rebuildDataSource(using: account)
        self.tableView?.reloadData()
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
        self.hideHud()
        rebuildDataSource(using: account)
        self.tableView?.reloadData()
    }

    func failed(error: FrameworkError) {
        hideHud()

        if isAddingAsset {
            self.displayAssetActivationError(error)
        } else {
            self.displayAssetDeactivationError(error)
        }
    }
}

// MARK: - FrameworkErrorPresentable
extension WalletSwitchingViewController: FrameworkErrorPresentable { }
