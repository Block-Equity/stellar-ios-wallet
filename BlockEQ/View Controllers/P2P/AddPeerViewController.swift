//
//  AddPeerViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Whisper
import StellarHub

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

//        guard let decimalLimit = Decimal(string: limit) else {
//            limitTextField.shake()
//            return
//        }

        view.endEditing(true)

        showHud()

        // Re-integreate this eventually to change the P2P trust once this feature is ratified.
        // createTrustLine(issuerAccountId: issuer, assetCode: assetCode, limit: decimalLimit)
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ADD_PEER".localized()

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    func setIssuerAddress(address: String) {
        issuerTextField.text = address
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "ADDING_PEER".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func displayAddPeerSuccess() {
        self.view.endEditing(true)

        let message = Message(title: "PEER_ADDED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }
}

extension AddPeerViewController: P2PResponseDelegate {
    func addedPeer() {
        self.hideHud()
        self.displayAddPeerSuccess()
    }

    func removedPeer() {
        self.hideHud()

        UIAlertController.simpleAlert(title: "ACTIVATION_ERROR_TITLE".localized(),
                                      message: "PEER_ERROR_MESSAGE".localized(),
                                      presentingViewController: self)
    }

    func created(personalToken: String) { }
    func createFailed(error: Error) { }
    func retrieved(personalToken: String?) {}
    func addFailed(error: Error) {}
    func removeFailed(error: Error) {}
}
