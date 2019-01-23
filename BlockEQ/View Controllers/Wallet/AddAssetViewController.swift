//
//  AddAssetViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol AddAssetViewControllerDelegate: class {
    func requestedAdd(_ viewController: AddAssetViewController, asset: StellarAsset)
}

class AddAssetViewController: UIViewController {
    @IBOutlet var assetCodeTextField: UITextField!
    @IBOutlet var issuerTextField: UITextField!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!

    weak var delegate: AddAssetViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        assetCodeTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        issuerTextField.text = ""
        assetCodeTextField.text = ""
        view.endEditing(true)
    }

    func setupView() {
        navigationItem.title = "ADD_ASSET".localized()

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    @IBAction func addAsset() {
        guard let assetCode = assetCodeTextField.text, !assetCode.isEmpty else {
            assetCodeTextField.shake()
            return
        }

        let selfAddress = StellarAddress(KeychainHelper.accountId)
        guard let issuer = StellarAddress(issuerTextField.text), issuer != selfAddress else {
            issuerTextField.shake()
            return
        }

        view.endEditing(true)

        let asset = StellarAsset(assetCode: assetCode, issuer: issuer.string)
        delegate?.requestedAdd(self, asset: asset)

        if self.isBeingPresented {
            navigationController?.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
