//
//  SideMenuViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate: class {
    func didSelect(asset: Assets.AssetType)
    func reloadAssets()
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderTitleLabel: UILabel!
    
    enum SectionType: Int {
        case userAssets
        case supportedAssets
    }
    
    let sections: [SectionType] = [.userAssets, .supportedAssets]
    let margin: CGFloat = 16.0
    
    weak var delegate: SideMenuViewControllerDelegate?
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var stellarAccount = StellarAccount()
    var updatedSupportedAssets: [Assets.AssetType] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: SideMenuViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
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
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: (navigationController?.navigationBar.frame.size.height)!))
        header.backgroundColor = Colors.transparent
        
        let titleLabel = UILabel(frame: CGRect(x: margin, y: 0, width: header.frame.size.width - margin * 2, height: header.frame.size.height))
        titleLabel.textColor = Colors.white
        titleLabel.backgroundColor = Colors.transparent
        titleLabel.text = "Wallets"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        header.addSubview(titleLabel)
        
        navigationController?.navigationBar.addSubview(header)
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
        
        print(updatedSupportedAssets.count)
        
        tableView.reloadData()
    }
}

extension SideMenuViewController: UITableViewDataSource {
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
            
            cell.titleLabel.text = stellarAccount.assets[indexPath.row].name
            cell.amountLabel.text = "\(stellarAccount.assets[indexPath.row].formattedBalance) \(stellarAccount.assets[indexPath.row].shortCode)"
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: WalletItemActivateCell.cellIdentifier, for: indexPath) as! WalletItemActivateCell
            
            cell.titleLabel.text = "Add \(updatedSupportedAssets[indexPath.row].rawValue) (\(updatedSupportedAssets[indexPath.row].shortForm))"
            
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

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionType.userAssets.rawValue:
            selectedIndexPath = indexPath
            
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
extension SideMenuViewController {
    func createTrustLine(asset: Assets.AssetType) {
        PaymentTransactionOperation.changeTrust(issuerAccountId: asset.issuerAccount, assetCode: asset.shortForm) { completed in
            if completed {
                print("Asset added")
                self.delegate?.reloadAssets()
            }
        }
    }
}
