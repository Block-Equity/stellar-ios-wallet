//
//  WalletSwitchingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

protocol WalletSwitchingViewControllerDelegate: class {
    func didSelectAsset(index: Int)
    func didSelectSetInflation(inflationDestination: String?)
    func didSelectAddAsset()
    func reloadAssets()
}

final class WalletSwitchingViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderTitleLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    enum SectionType: Int {
        case userAssets
        case supportedAssets
    }

    let sections: [SectionType] = [.userAssets, .supportedAssets]
    let margin: CGFloat = 16.0

    weak var delegate: WalletSwitchingViewControllerDelegate?
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var stellarAccount = StellarAccount()
    var updatedSupportedAssets: [Assets.AssetType] = []
    var allAssets: [StellarAsset] = []

    @IBAction func addAsset() {
        if isZeroBalance() {
            displayNoBalanceError()
        } else {
            delegate?.didSelectAddAsset()
        }
    }

    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getAccountDetails()
    }

    func setupView() {
        addNavigationHeader()

        tableViewHeader.backgroundColor = Colors.lightBackground
        tableViewHeaderTitleLabel.textColor = Colors.darkGray

        let tableViewNibUserAssets = UINib(nibName: WalletItemCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibUserAssets, forCellReuseIdentifier: WalletItemCell.cellIdentifier)

        let tableViewNibSupportedAssets = UINib(nibName: WalletItemActivateCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibSupportedAssets, forCellReuseIdentifier: WalletItemActivateCell.cellIdentifier)
    }

    func addNavigationHeader() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ASSETS".localized()
    }

    func updateMenu(stellarAccount: StellarAccount) {
        self.stellarAccount = stellarAccount

        updatedSupportedAssets.removeAll()
        allAssets.removeAll()

        allAssets.append(contentsOf: stellarAccount.assets)

        let allTypes = Set(Assets.all)
        let assetTypesOnAccount: [Assets.AssetType] = stellarAccount.assets.compactMap {
            guard let code = $0.assetCode else { return nil }
            return Assets.AssetType(rawValue: code)
        }

        let missingTypes = allTypes.symmetricDifference(Set(assetTypesOnAccount))
        updatedSupportedAssets.append(contentsOf: missingTypes)

        tableView?.reloadData()
    }

    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = message
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func isZeroBalance() -> Bool {
        guard let balance = Double(allAssets[0].balance) else {
            return false
        }

        if stellarAccount.assets.count == 1 && balance < 1.0 {
            return true
        }

        return false
    }

    func displayAssetActivationError() {
        let alert = UIAlertController(title: "ACTIVATION_ERROR_TITLE".localized(),
                                      message: "ASSET_BALANCE_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func displayAssetDeactivationError() {
        let alert = UIAlertController(title: "ACTIVATION_ERROR_TITLE".localized(),
                                      message: "ASSET_REMOVE_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func displayNoBalanceError() {
        let alert = UIAlertController(title: "NO_BALANCE_ERROR_TITLE".localized(),
                                      message: "LOW_BALANCE_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension WalletSwitchingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case SectionType.userAssets.rawValue:
            return nil
        default:
            if updatedSupportedAssets.count > 0 {
                return tableViewHeader
            }
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionType.userAssets.rawValue:
            return 0
        default:
            if updatedSupportedAssets.count > 0 {
                return tableViewHeader.frame.size.height
            }
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionType.userAssets.rawValue:
            return allAssets.count
        default:
            return updatedSupportedAssets.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            let item = allAssets[indexPath.row]
            let walletCell: WalletItemCell = tableView.dequeueReusableCell(for: indexPath)

            walletCell.indexPath = indexPath
            walletCell.delegate = self
            walletCell.titleLabel.text = Assets.displayTitle(shortCode: item.shortCode)
            walletCell.amountLabel.text = "\(item.formattedBalance) \(item.shortCode)"
            walletCell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: item.shortCode)
            if let image = Assets.displayImage(shortCode: item.shortCode) {
                walletCell.iconImageView.image = image
                walletCell.tokenInitialLabel.text = ""
            } else {
                walletCell.iconImageView.image = nil
                let shortcode = Assets.displayTitle(shortCode: item.shortCode)
                walletCell.tokenInitialLabel.text = String(Array(shortcode)[0])
            }

            if item.shortCode == "XLM" {
                walletCell.removeAssetButton.isHidden = true
                if stellarAccount.inflationDestination != nil {
                    walletCell.setInflationButton.isHidden = true
                    walletCell.updateInflationButton.isHidden = false
                } else {
                    walletCell.setInflationButton.isHidden = false
                    walletCell.updateInflationButton.isHidden = true
                }
            } else {
                walletCell.removeAssetButton.isHidden = false
                walletCell.setInflationButton.isHidden = true
                walletCell.updateInflationButton.isHidden = true
            }

            return walletCell
        default:
            let shortCode = updatedSupportedAssets[indexPath.row].shortForm
            let displayString = String(format: "%@ %@", Assets.displayTitle(shortCode: shortCode), shortCode)

            let walletCell: WalletItemActivateCell = tableView.dequeueReusableCell(for: indexPath)

            walletCell.indexPath = indexPath
            walletCell.delegate = self
            walletCell.titleLabel.text = displayString
            walletCell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: shortCode)
            walletCell.iconImageView.image = Assets.displayImage(shortCode: shortCode)

            return walletCell
        }
    }
}

extension WalletSwitchingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            selectedIndexPath = indexPath

            delegate?.didSelectAsset(index: indexPath.row)

            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

extension WalletSwitchingViewController: WalletItemCellDelegate {
    func didChangeInflation() {
        if isZeroBalance() {
            displayNoBalanceError()
        } else {
            delegate?.didSelectSetInflation(inflationDestination: stellarAccount.inflationDestination)
        }
    }

    func didRemoveAsset(indexPath: IndexPath) {
        let item = allAssets[indexPath.row]
        createTrustLine(issuerAccountId: item.assetIssuer!,
                        assetCode: item.shortCode,
                        limit: 0.0000000,
                        isAdding: false)
    }
}

extension WalletSwitchingViewController: WalletItemActivateCellDelegate {
    func didAddAsset(indexPath: IndexPath) {
        if isZeroBalance() {
            displayNoBalanceError()
        } else {
            let item = updatedSupportedAssets[indexPath.row]
            createTrustLine(issuerAccountId: item.issuerAccount,
                            assetCode: item.shortForm,
                            limit: 10000000000,
                            isAdding: true)
        }
    }
}

/*
 * Operations
 */
extension WalletSwitchingViewController {
    func createTrustLine(issuerAccountId: String, assetCode: String, limit: Decimal, isAdding: Bool) {
        let message = isAdding ? "ACTIVATE_ASSET".localized() : "REMOVE_ASSET".localized()
        showHud(message: message)

        PaymentTransactionOperation.changeTrust(issuerAccountId: issuerAccountId,
                                                assetCode: assetCode,
                                                limit: limit) { completed in
            if completed {
               self.getAccountDetails()
            } else {
                self.hideHud()

                if isAdding {
                    self.displayAssetActivationError()
                } else {
                    self.displayAssetDeactivationError()
                }
            }
        }
    }

    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.hideHud()

            if responseAccounts.count > 0 {
                self.updateMenu(stellarAccount: responseAccounts[0])
                self.delegate?.reloadAssets()
            }
        }
    }
}
