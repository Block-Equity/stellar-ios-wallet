//
//  SelectAssetViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-16.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class SelectAssetViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var allAssets: [StellarAsset] = []
    var receiver: String = ""
    var stellarAccount = StellarAccount()
    var exchangeName: String?
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(stellarAccount: StellarAccount, receiver: String, exchangeName: String?) {
        super.init(nibName: String(describing: SelectAssetViewController.self), bundle: nil)
        
        self.receiver = receiver
        self.stellarAccount = stellarAccount
        self.exchangeName = exchangeName
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationItem.title = "Select Asset"
        
        let closeButton = UIImage(named: "close")
        let rightBarButtonItem = UIBarButtonItem(image: closeButton, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let tableViewNibAssets = UINib(nibName: SelectAssetCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibAssets, forCellReuseIdentifier: SelectAssetCell.cellIdentifier)
        
        allAssets.removeAll()
        
        for asset in stellarAccount.assets {
            allAssets.append(asset)
        }
        
        tableView?.reloadData()
    }
}

extension SelectAssetViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAssets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectAssetCell.cellIdentifier, for: indexPath) as! SelectAssetCell
        
        cell.titleLabel.text = Assets.displayTitle(shortCode:allAssets[indexPath.row].shortCode)
        cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: allAssets[indexPath.row].shortCode)
        if let image = Assets.displayImage(shortCode: allAssets[indexPath.row].shortCode) {
            cell.iconImageView.image = image
            cell.tokenInitialLabel.text = ""
        } else {
            cell.iconImageView.image = nil
            let shortcode = Assets.displayTitle(shortCode:allAssets[indexPath.row].shortCode)
            cell.tokenInitialLabel.text = String(Array(shortcode)[0])
        }
        
        if allAssets[indexPath.row].assetType == AssetTypeAsString.NATIVE {
            cell.amountLabel.text = "\(stellarAccount.formattedAvailableBalance) \(allAssets[indexPath.row].shortCode)"
        } else {
            cell.amountLabel.text = "\(allAssets[indexPath.row].formattedBalance) \(allAssets[indexPath.row].shortCode)"
        }
        
        return cell
    }
}

extension SelectAssetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let sendAmountViewController = SendAmountViewController(stellarAccount: stellarAccount, currentAssetIndex: indexPath.row, receiver: receiver, exchangeName: exchangeName)
        self.navigationController?.pushViewController(sendAmountViewController, animated: true)
        
    }
}

