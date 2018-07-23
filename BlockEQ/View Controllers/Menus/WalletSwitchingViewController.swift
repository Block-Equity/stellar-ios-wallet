//
//  WalletSwitchingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol WalletSwitchingViewControllerDelegate: class {
    func didSelectAsset(index: Int)
    func didSelectSetInflation(inflationDestination: String?)
    func didSelectAddAsset()
    func reloadAssets()
}

final class WalletSwitchingViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
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
    
    //TODO: Remove
    /*
    @IBAction func setInflation() {
        delegate?.didSelectSetInflation()
    }*/
    
    @IBAction func addAsset() {
        if isZeroBalance() {
            displayNoBalanceError()
        } else {
            delegate?.didSelectAddAsset()
        }
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
        tableView?.register(tableViewNibUserAssets, forCellReuseIdentifier: WalletItemCell.cellIdentifier)
        
        let tableViewNibSupportedAssets = UINib(nibName: WalletItemActivateCell.cellIdentifier, bundle: nil)
        tableView?.register(tableViewNibSupportedAssets, forCellReuseIdentifier: WalletItemActivateCell.cellIdentifier)
    }
    
    func addNavigationHeader() {
        self.title = "Assets".localized()

        let closeButton = UIImage(named: "close")
        let rightBarButtonItem = UIBarButtonItem(image: closeButton, style: .plain, target: self, action: #selector(self.close))

        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateMenu(stellarAccount: StellarAccount) {
        
        self.stellarAccount = stellarAccount
        
        updatedSupportedAssets.removeAll()
        
        for supportedAsset in Assets.all {
            var isMatch = false
            for asset in stellarAccount.assets {
                if supportedAsset.shortForm == asset.shortCode {
                    isMatch = true
                    break
                }
            }
            
            if !isMatch {
                updatedSupportedAssets.append(supportedAsset)
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
    
    func isZeroBalance() -> Bool {
        if stellarAccount.assets.count == 1 && Double(stellarAccount.assets[0].balance)! < 1 {
            return true
        }
        return false
    }
    
    func displayAssetActivationError() {
        let alert = UIAlertController(title: "Activation Error", message: "Sorry your asset could not be added at this time. You may need to add more Lumens(XLM) to your wallet and try again as each action costs 0.5 XLM.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAssetDeactivationError() {
        let alert = UIAlertController(title: "Activation Error", message: "Sorry your asset could not be removed at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayNoBalanceError() {
        let alert = UIAlertController(title: "No Balance Error", message: "You must have more than 1 Lumen (XLM) in order to perform this action.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
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
            return stellarAccount.assets.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: WalletItemCell.cellIdentifier, for: indexPath) as! WalletItemCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.titleLabel.text = Assets.displayTitle(shortCode:stellarAccount.assets[indexPath.row].shortCode)
            cell.amountLabel.text = "\(stellarAccount.assets[indexPath.row].formattedBalance) \(stellarAccount.assets[indexPath.row].shortCode)"
            cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: stellarAccount.assets[indexPath.row].shortCode)
            if let image = Assets.displayImage(shortCode: stellarAccount.assets[indexPath.row].shortCode) {
                cell.iconImageView.image = image
                cell.tokenInitialLabel.text = ""
            } else {
                cell.iconImageView.image = nil
                let shortcode = Assets.displayTitle(shortCode:stellarAccount.assets[indexPath.row].shortCode)
                cell.tokenInitialLabel.text = String(Array(shortcode)[0])
            }
            
            if stellarAccount.assets[indexPath.row].shortCode == "XLM" {
                cell.removeAssetButton.isHidden = true
                if let _ = stellarAccount.inflationDestination {
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: WalletItemActivateCell.cellIdentifier, for: indexPath) as! WalletItemActivateCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.titleLabel.text = "\(Assets.displayTitle(shortCode: updatedSupportedAssets[indexPath.row].shortForm)) (\(updatedSupportedAssets[indexPath.row].shortForm))"
            cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: updatedSupportedAssets[indexPath.row].shortForm)
            cell.iconImageView.image = Assets.displayImage(shortCode: updatedSupportedAssets[indexPath.row].shortForm)
            
            return cell
        }
    }
    
    //TODO: Need to move to coordinator in order to show correct selection
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
        default:
            break
        }
    }*/
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
            break;
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
        createTrustLine(issuerAccountId:stellarAccount.assets[indexPath.row].assetIssuer!, assetCode:stellarAccount.assets[indexPath.row].shortCode, limit: 0.0000000, isAdding: false)
    }
}

extension WalletSwitchingViewController: WalletItemActivateCellDelegate {
    func didAddAsset(indexPath: IndexPath) {
        if isZeroBalance() {
            displayNoBalanceError()
        } else {
            createTrustLine(issuerAccountId: updatedSupportedAssets[indexPath.row].issuerAccount, assetCode: updatedSupportedAssets[indexPath.row].shortForm, limit: 10000000000, isAdding: true)
        }
    }
}

/*
 * Operations
 */
extension WalletSwitchingViewController {
    func createTrustLine(issuerAccountId: String, assetCode: String, limit: Decimal, isAdding: Bool) {
        if isAdding {
            showHud(message: "Activating Asset...")
        } else {
            showHud(message: "Removing Asset...")
        }
        
        PaymentTransactionOperation.changeTrust(issuerAccountId: issuerAccountId, assetCode: assetCode, limit: limit) { completed
            in
            if completed {
               self.getAccountDetails()
            } else {
                self.hideHud()
                
                if isAdding {
                    self.displayAssetActivationError()
                } else {
                    self.displayAssetActivationError()
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
