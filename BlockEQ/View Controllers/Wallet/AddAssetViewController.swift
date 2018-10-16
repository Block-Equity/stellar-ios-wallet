//
//  AddAssetViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

protocol AddAssetViewControllerDelegate: class {
    func didAddAsset(stellarAccount: StellarAccount)
}

class AddAssetViewController: UIViewController {

    @IBOutlet var assetCodeTextField: UITextField!
    @IBOutlet var issuerTextField: UITextField!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!

    weak var delegate: AddAssetViewControllerDelegate?

    @IBAction func addAsset() {
        guard let assetCode = assetCodeTextField.text, !assetCode.isEmpty else {
            assetCodeTextField.shake()
            return
        }

        guard let issuer = issuerTextField.text, !issuer.isEmpty, issuer.count > 20 else {
            issuerTextField.shake()
            return
        }

        view.endEditing(true)

        createTrustLine(issuerAccountId: issuer, assetCode: assetCode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        assetCodeTextField.becomeFirstResponder()
    }

    func setupView() {
        navigationItem.title = "Add Asset".localized()

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Adding Asset..."
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }
}

/*
 * Operations
 */
extension AddAssetViewController {
    func createTrustLine(issuerAccountId: String, assetCode: String) {
        showHud()

        PaymentTransactionOperation.changeTrust(issuerAccountId: issuerAccountId,
                                                assetCode: assetCode,
                                                limit: nil) { completed in
            if completed {
                self.getAccountDetails()
            } else {
                self.hideHud()

                let alert = UIAlertController(title: "ACTIVATION_ERROR_TITLE".localized(),
                                              message: "ASSET_ERROR_MESSAGE".localized(),
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(),
                                              style: .default,
                                              handler: nil))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func getAccountDetails() {
        guard let accountId = KeychainHelper.accountId else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.hideHud()

            if responseAccounts.count > 0 {
                self.delegate?.didAddAsset(stellarAccount: responseAccounts[0])
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
