//
//  SendViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

class SendViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendTitleLabel: UILabel!
    @IBOutlet var sendAddressTextField: UITextField!

    var stellarAccount: StellarAccount = StellarAccount()
    var currentAssetIndex = 0

    @IBAction func addAmount() {
        guard let receiver = sendAddressTextField.text,
            !receiver.isEmpty,
            receiver.count > 20,
            receiver != KeychainHelper.accountId else {
                sendAddressTextField.shake()
                return
        }

        showHud()

        PaymentTransactionOperation.checkForExchange(address: receiver) { address in
            self.view.endEditing(true)
            self.hideHud()

            let sendAmountViewController = SendAmountViewController(stellarAccount: self.stellarAccount,
                                                                    currentAssetIndex: self.currentAssetIndex,
                                                                    receiver: receiver,
                                                                    exchangeName: address)

            self.navigationController?.pushViewController(sendAmountViewController, animated: true)
        }
    }

    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }

    init(stellarAccount: StellarAccount, currentAssetIndex: Int) {
        super.init(nibName: String(describing: SendViewController.self), bundle: nil)

        self.stellarAccount = stellarAccount
        self.currentAssetIndex = currentAssetIndex
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

        var availableBalance = ""
        if stellarAccount.assets[currentAssetIndex].assetType == AssetTypeAsString.NATIVE {
            availableBalance = stellarAccount.formattedAvailableBalance
        } else {
            availableBalance = stellarAccount.assets[currentAssetIndex].formattedBalance
        }

        navigationItem.title = "\(availableBalance) \(stellarAccount.assets[currentAssetIndex].shortCode)"
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
