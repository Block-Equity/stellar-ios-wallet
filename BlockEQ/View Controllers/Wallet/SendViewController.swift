//
//  SendViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

class SendViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendTitleLabel: UILabel!
    @IBOutlet var sendAddressTextField: UITextField!

    var accountService: AccountManagementService
    var currentAsset: StellarAsset?

    @IBAction func addAmount() {
        guard let receiver = StellarAddress(sendAddressTextField.text),
            receiver.string != KeychainHelper.accountId else {
                sendAddressTextField.shake()
                return
        }

        guard let asset = self.currentAsset else { return }

        self.view.endEditing(true)

        let exchange: Exchange? = AddressResolver.resolve(address: receiver)
        let sendAmountViewController = SendAmountViewController(service: accountService,
                                                                currentAsset: asset,
                                                                receiver: receiver,
                                                                exchangeName: exchange?.name)

        self.navigationController?.pushViewController(sendAmountViewController, animated: true)
    }

    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }

    init(service: AccountManagementService, asset: StellarAsset) {
        self.accountService = service
        self.currentAsset = asset

        super.init(nibName: String(describing: SendViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setViewStateToNotEditing()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "NAVIGATE_BACK".localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        sendTitleLabel.textColor = Colors.darkGrayTransparent
        sendAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground

        guard let asset = self.currentAsset, let account = accountService.account else { return }

        var availableBalance = ""
        if asset.assetType == AssetTypeAsString.NATIVE {
            availableBalance = account.availableBalance.tradeFormattedString
        } else {
            availableBalance = asset.balance.displayFormatted
        }

        navigationItem.title = String(format: "TRADE_BALANCE_FORMAT".localized(), availableBalance, asset.shortCode)
    }

    func setViewStateToNotEditing() {
        view.endEditing(true)
    }

    @objc func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }
}

extension SendViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        sendAddressTextField.text = value
    }
}
