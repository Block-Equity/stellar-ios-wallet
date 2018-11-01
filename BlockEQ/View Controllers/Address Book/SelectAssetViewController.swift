//
//  SelectAssetViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-16.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

class SelectAssetViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var allAssets: [StellarAsset] = []
    var receiver: StellarAddress
    var accountService: StellarAccountService
    var exchangeName: String?

    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    init(service: StellarAccountService, receiver: StellarAddress, exchangeName: String?) {
        self.receiver = receiver
        self.accountService = service
        self.exchangeName = exchangeName

        super.init(nibName: String(describing: SelectAssetViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "SELECT_ASSET".localized()

        let tableViewNibAssets = UINib(nibName: SelectAssetCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibAssets, forCellReuseIdentifier: SelectAssetCell.cellIdentifier)

        allAssets.removeAll()

        guard let account = accountService.account else { return }

        for asset in account.assets {
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
        let item = allAssets[indexPath.row]
        let cell: SelectAssetCell = tableView.dequeueReusableCell(for: indexPath)

        cell.titleLabel.text = Assets.displayTitle(shortCode: item.shortCode)
        cell.iconImageView.backgroundColor = Assets.displayImageBackgroundColor(shortCode: item.shortCode)
        if let image = Assets.displayImage(shortCode: item.shortCode) {
            cell.iconImageView.image = image
            cell.tokenInitialLabel.text = ""
        } else {
            cell.iconImageView.image = nil
            let shortcode = Assets.displayTitle(shortCode: item.shortCode)
            cell.tokenInitialLabel.text = String(Array(shortcode)[0])
        }

        if let account = accountService.account, item.assetType == AssetTypeAsString.NATIVE {
            cell.amountLabel.text = "\(account.formattedAvailableBalance) \(item.shortCode)"
        } else {
            cell.amountLabel.text = "\(allAssets[indexPath.row].balance.displayFormatted) \(item.shortCode)"
        }

        return cell
    }
}

extension SelectAssetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let account = accountService.account else { return }

        let asset = account.assets[indexPath.row]
        let sendAmountViewController = SendAmountViewController(service: accountService,
                                                                currentAsset: asset,
                                                                receiver: receiver,
                                                                exchangeName: exchangeName)

        self.navigationController?.pushViewController(sendAmountViewController, animated: true)
    }
}
