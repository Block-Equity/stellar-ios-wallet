//
//  CreateTokenViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Whisper
import UIKit

class CreateTokenViewController: UIViewController {
    @IBOutlet var tokenNameTextField: UITextField!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tokenNameTextField.becomeFirstResponder()
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "CREATE_TOKEN".localized()

        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "CREATING_TOKEN".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func displayCreateTokenSuccess() {
        self.view.endEditing(true)

        let message = Message(title: "CREATED_TOKEN".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }

    @IBAction func createPersonalToken() {
        guard let tokenName = tokenNameTextField.text, !tokenName.isEmpty else {
            tokenNameTextField.shake()
            return
        }

        view.endEditing(true)

        createToken(assetCode: "\(tokenName)XLM")
    }

    @IBAction func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }
}

extension CreateTokenViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 8
    }
}

/*
 * Operations
 */
extension CreateTokenViewController {
    func createToken(assetCode: String) {
        showHud()

        AccountOperation.createPersonalToken(assetCode: assetCode) { completed
            in
            self.hideHud()

            if completed {
                self.displayCreateTokenSuccess()
            } else {
                let alert = UIAlertController(title: "ACTIVATION_ERROR_TITLE".localized(),
                                              message: "TOKEN_ERROR_MESSAGE".localized(),
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
