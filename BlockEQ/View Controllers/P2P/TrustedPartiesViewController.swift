//
//  TrustedPartiesViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

class TrustedPartiesViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var stellarAccount = StellarAccount()
    var peers: [StellarAsset] = []

    @IBAction func addPeer() {

    }

    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
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
        let leftBarButtonItem = UIBarButtonItem(title: "ADD_PEER".localized(),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self.addPeer))

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.title = "TRUSTED_PEERS".localized()

        let tableViewNibUserAssets = UINib(nibName: WalletItemCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibUserAssets, forCellReuseIdentifier: WalletItemCell.cellIdentifier)
    }

    func updateMenu(stellarAccount: StellarAccount) {
        self.stellarAccount = stellarAccount

        peers.removeAll()

        for asset in stellarAccount.assets {
            if asset.shortCode.contains("XLM") && asset.assetType == AssetTypeAsString.CREDIT_ALPHANUM12 {
                peers.append(asset)
            }
        }

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

    func displayAssetDeactivationError() {
        let alert = UIAlertController(title: "ACTIVATION_ERROR_TITLE".localized(),
                                      message: "ASSET_REMOVE_ERROR_MESSAGE".localized(),
                                      preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(),
                                      style: UIAlertActionStyle.default,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension TrustedPartiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = peers[indexPath.row]
        let cell: WalletItemCell = tableView.dequeueReusableCell(for: indexPath)

        cell.indexPath = indexPath
        cell.delegate = self
        cell.titleLabel.text = Assets.displayTitle(shortCode: item.shortCode)
        cell.amountLabel.text = "\(item.formattedBalance) \(item.shortCode)"
        cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: item.shortCode)

        if let image = Assets.displayImage(shortCode: item.shortCode) {
            cell.iconImageView.image = image
            cell.tokenInitialLabel.text = ""
        } else {
            cell.iconImageView.image = nil
            let shortcode = Assets.displayTitle(shortCode: item.shortCode)
            cell.tokenInitialLabel.text = String(Array(shortcode)[0])
        }

        if peers[indexPath.row].shortCode == "XLM" {
            cell.removeAssetButton.isHidden = true
            if stellarAccount.inflationDestination != nil {
                cell.setInflationButton.isHidden = true
                cell.updateInflationButton.isHidden = false
            } else {
                cell.setInflationButton.isHidden = false
                cell.updateInflationButton.isHidden = true
            }
        } else {
            cell.removeAssetButton.isHidden = false
            cell.setInflationButton.isHidden = true
            cell.updateInflationButton.isHidden = true
        }

        return cell
    }
}

extension TrustedPartiesViewController: WalletItemCellDelegate {
    func didChangeInflation() {}

    func didRemoveAsset(indexPath: IndexPath) {
        removeTrustLine(issuerAccountId: peers[indexPath.row].assetIssuer!,
                        assetCode: peers[indexPath.row].shortCode,
                        limit: 0.0000000)
    }
}

/*
 * Operations
 */
extension TrustedPartiesViewController {
    func removeTrustLine(issuerAccountId: String, assetCode: String, limit: Decimal) {
        showHud(message: "Removing Asset...")

        PaymentTransactionOperation.changeP2PTrust(issuerAccountId: issuerAccountId,
                                                   assetCode: assetCode,
                                                   limit: limit) { completed in
            if completed {
                self.getAccountDetails()
            } else {
                self.hideHud()
                self.displayAssetDeactivationError()
            }
        }
    }

    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.hideHud()
            self.activityIndicator.stopAnimating()

            if responseAccounts.count > 0 {
                self.updateMenu(stellarAccount: responseAccounts[0])
            }
        }
    }
}
