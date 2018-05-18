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
    func didSelectSetInflation()
    func reloadAssets()
}

final class WalletSwitchingViewController: UIViewController {
    
    @IBOutlet var inflationButton: UIButton!
    @IBOutlet var tableView: UITableView?
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderTitleLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

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
    
    @IBAction func setInflation() {
        delegate?.didSelectSetInflation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: WalletSwitchingViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        addNavigationHeader()

        inflationButton.setTitleColor(Colors.white, for: .normal)
        inflationButton.backgroundColor = Colors.green
        tableViewHeader.backgroundColor = Colors.lightBackground
        tableViewHeaderTitleLabel.textColor = Colors.darkGray
        
        inflationButton.setTitle("Set Inflation", for: .normal)
        
        let tableViewNibUserAssets = UINib(nibName: WalletItemCell.cellIdentifier, bundle: nil)
        tableView?.register(tableViewNibUserAssets, forCellReuseIdentifier: WalletItemCell.cellIdentifier)
        
        let tableViewNibSupportedAssets = UINib(nibName: WalletItemActivateCell.cellIdentifier, bundle: nil)
        tableView?.register(tableViewNibSupportedAssets, forCellReuseIdentifier: WalletItemActivateCell.cellIdentifier)
    }
    
    func addNavigationHeader() {
        self.title = "Wallets".localized()

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
    
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Activating Wallet..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
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
            
            cell.titleLabel.text = Assets.displayTitle(shortCode:stellarAccount.assets[indexPath.row].shortCode)
            cell.amountLabel.text = "\(stellarAccount.assets[indexPath.row].formattedBalance) \(stellarAccount.assets[indexPath.row].shortCode)"
            cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: stellarAccount.assets[indexPath.row].shortCode)
            cell.iconImageView.image = Assets.displayImage(shortCode: stellarAccount.assets[indexPath.row].shortCode)
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: WalletItemActivateCell.cellIdentifier, for: indexPath) as! WalletItemActivateCell
            
            cell.titleLabel.text = "Add \(Assets.displayTitle(shortCode: updatedSupportedAssets[indexPath.row].shortForm)) (\(updatedSupportedAssets[indexPath.row].shortForm))"
            cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: updatedSupportedAssets[indexPath.row].shortForm)
            cell.iconImageView.image = Assets.displayImage(shortCode: updatedSupportedAssets[indexPath.row].shortForm)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
        default:
            break
        }
    }
}

extension WalletSwitchingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            selectedIndexPath = indexPath
            
            delegate?.didSelectAsset(index: indexPath.row)
            
            dismiss(animated: true, completion: nil)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            
            createTrustLine(asset: updatedSupportedAssets[indexPath.row])
        }
    }
}

/*
 * Operations
 */
extension WalletSwitchingViewController {
    func createTrustLine(asset: Assets.AssetType) {
        showHud()
        
        PaymentTransactionOperation.changeTrust(issuerAccountId: asset.issuerAccount, assetCode: asset.shortForm) { completed
            in
            self.hideHud()
            
            if completed {
                self.delegate?.reloadAssets()
            } else {
                let alert = UIAlertController(title: "Activation Error", message: "Sorry your wallet could not be activated at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
