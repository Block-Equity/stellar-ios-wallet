//
//  AddressEntryViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol AddressEntryViewControllerDelegate: AnyObject {
    func completedAddressEntry(_ viewController: AddressEntryViewController, address: StellarAddress)
    func cancelledAddressEntry(_ viewController: AddressEntryViewController)
    func requestedScanQRCode(_ viewController: AddressEntryViewController)
}

final class AddressEntryViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var sendTitleLabel: UILabel!
    @IBOutlet var sendAddressTextField: UITextField!

    weak var delegate: AddressEntryViewControllerDelegate?

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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "NAVIGATE_BACK".localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        sendTitleLabel.textColor = Colors.darkGrayTransparent
        sendAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: view, animated: true)
    }

    func update(with account: StellarAccount, asset: StellarAsset) {
        let availableSendBalance = account.availableSendBalance(for: asset).displayFormattedString
        navigationItem.title = String(format: "TRADE_BALANCE_FORMAT".localized(), availableSendBalance, asset.shortCode)
    }
}

// MARK: - IBActions
extension AddressEntryViewController {
    @IBAction func addAmount() {
        guard let receiver = StellarAddress(sendAddressTextField.text),
            receiver.string != KeychainHelper.accountId else {
                sendAddressTextField.shake()
                return
        }

        view.endEditing(true)

        delegate?.completedAddressEntry(self, address: receiver)
    }

    @IBAction func scanQRCode() {
        delegate?.requestedScanQRCode(self)
    }

    @objc func dismissView() {
        view.endEditing(true)
        delegate?.cancelledAddressEntry(self)
    }
}

extension AddressEntryViewController: ScanViewControllerDelegate {
    func setQR(_ viewController: ScanViewController, value: String) {
        sendAddressTextField.text = value
    }
}
