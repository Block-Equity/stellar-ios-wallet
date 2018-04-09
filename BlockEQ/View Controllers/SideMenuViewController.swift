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
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let margin: CGFloat = 16.0
    
    weak var delegate: SideMenuViewControllerDelegate?
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var stellarAccount = StellarAccount()
    
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
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: (navigationController?.navigationBar.frame.size.height)!))
        header.backgroundColor = Colors.transparent
        
        let titleLabel = UILabel(frame: CGRect(x: margin, y: 0, width: header.frame.size.width - margin * 2, height: header.frame.size.height))
        titleLabel.textColor = Colors.white
        titleLabel.backgroundColor = Colors.transparent
        titleLabel.text = "Wallets"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        header.addSubview(titleLabel)
        
        navigationController?.navigationBar.addSubview(header)
        
        let tableViewNib = UINib(nibName: WalletItemCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: WalletItemCell.cellIdentifier)
    }
    
    func updateMenu(stellarAccount: StellarAccount) {
        self.stellarAccount = stellarAccount
        
        tableView.reloadData()
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stellarAccount.assets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletItemCell.cellIdentifier, for: indexPath) as! WalletItemCell
        
        cell.titleLabel.text = stellarAccount.assets[indexPath.row].name
        cell.amountLabel.text = "\(stellarAccount.assets[indexPath.row].formattedBalance) \(stellarAccount.assets[indexPath.row].shortCode)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        delegate?.didSelect(asset: Assets.all[indexPath.row])
        
        dismiss(animated: true, completion: nil)
    }
}
