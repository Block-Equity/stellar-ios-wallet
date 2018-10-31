//
//  SendViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

class SendViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendTitleLabel: UILabel!
    @IBOutlet var sendAddressTextField: UITextField!

    var stellarAccount: StellarAccount
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
        let sendAmountViewController = SendAmountViewController(stellarAccount: self.stellarAccount,
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

    init(stellarAccount: StellarAccount, asset: StellarAsset) {
        self.stellarAccount = stellarAccount
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

        guard let asset = self.currentAsset else { return }

        var availableBalance = ""
        if asset.assetType == AssetTypeAsString.NATIVE {
            availableBalance = stellarAccount.formattedAvailableBalance
        } else {
            availableBalance = asset.balance.decimalFormatted
        }

        navigationItem.title = "\(availableBalance) \(asset.shortCode)"
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
