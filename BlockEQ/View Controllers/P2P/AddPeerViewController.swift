//
//  AddPeerViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-12.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Whisper
import UIKit

protocol AddPeerViewControllerDelegate: AnyObject {
    func selectedScanAddress()
}

class AddPeerViewController: UIViewController {

    @IBOutlet var assetCodeTextField: UITextField!
    @IBOutlet var issuerTextField: UITextField!
    @IBOutlet var limitTextField: UITextField!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!

    weak var delegate: AddPeerViewControllerDelegate?

    @IBAction func scanAddress() {
        delegate?.selectedScanAddress()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    @IBAction func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func addTrustLineToPeer() {
        guard let assetCode = assetCodeTextField.text, !assetCode.isEmpty else {
            assetCodeTextField.shake()
            return
        }

        guard let issuer = issuerTextField.text, !issuer.isEmpty, issuer.count > 20 else {
            issuerTextField.shake()
            return
        }

        guard let limit = limitTextField.text, !limit.isEmpty else {
            limitTextField.shake()
            return
        }

        guard let decimalLimit = Decimal(string: limit) else {
            limitTextField.shake()
            return
        }

        view.endEditing(true)

        createTrustLine(issuerAccountId: issuer, assetCode: assetCode, limit: decimalLimit)
    }

    func setupView() {
        navigationItem.title = "Add Peer".localized()

        let image = UIImage(named: "close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    func setIssuerAddress(address: String) {
        issuerTextField.text = address
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Adding Peer..."
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func displayAddPeerSuccess() {
        self.view.endEditing(true)

        let message = Message(title: "Peer successfully added.", backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }
}

/*
 * Operations
 */
extension AddPeerViewController {
    func createTrustLine(issuerAccountId: String, assetCode: String, limit: Decimal) {
        showHud()

        PaymentTransactionOperation.changeP2PTrust(issuerAccountId: issuerAccountId, assetCode: assetCode, limit: limit) { completed
            in
            self.hideHud()
            if completed {
                self.displayAddPeerSuccess()
            } else {
                let alert = UIAlertController(title: "Activation Error", message: "Sorry this peer could not be added at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
