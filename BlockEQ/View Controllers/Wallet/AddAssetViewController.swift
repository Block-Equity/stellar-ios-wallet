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

    func setupView() {
        navigationItem.title = "ADD_ASSET".localized()

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "ADDING_ASSET".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    @IBAction func addAsset() {
        guard let assetCode = assetCodeTextField.text, !assetCode.isEmpty else {
            assetCodeTextField.shake()
            return
        }

        guard let issuer = StellarAddress(issuerTextField.text) else {
            issuerTextField.shake()
            return
        }

        view.endEditing(true)
        showHud()

        let asset = StellarAsset(assetCode: assetCode, issuer: issuer.string)
        self.delegate?.requestedAdd(self, asset: asset)

        if self.isBeingPresented {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
