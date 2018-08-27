//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Whisper
import stellarsdk
import UIKit

class SendAmountViewController: UIViewController {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var exchangeLabel: UILabel!
    @IBOutlet var exchangeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var exchangeHolderView: UIView!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var keyboardHolderView: KeyboardView!
    @IBOutlet var memoIdLabel: UILabel!
    @IBOutlet var memoIdTextField: UITextField!
    @IBOutlet var sendAddressLabel: UILabel!
    @IBOutlet var toolBar: UIToolbar!

    let decimalCountRestriction = 7
    let decimalDotSize = 1

    var receiver: String = ""
    var sendingAmount: String = "0"
    var stellarAccount: StellarAccount = StellarAccount()
    var currentAssetIndex = 0
    var isExchangeAddress: Bool = false
    var exchangeName: String = ""
    var authenticationCoordinator: AuthenticationCoordinator?

    @IBAction func sendPayment() {
        guard let amount = amountLabel.text, !amount.isEmpty, amount != "0", isValidSendAmount(amount: amount) else {
            amountLabel.shake()
            return
        }

        if isExchangeAddress {
            guard let memo = memoIdTextField.text, !memo.isEmpty else {
                memoIdLabel.shake()
                return
            }
        }

        if SecurityOptionHelper.check(.pinOnPayment) {
            authenticate()
        } else {
            sendPaymentAmount()
        }
    }

    @IBAction func clearTextfield() {
        view.endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(stellarAccount: StellarAccount, currentAssetIndex: Int, receiver: String, exchangeName: String?) {
        super.init(nibName: String(describing: SendAmountViewController.self), bundle: nil)

        self.receiver = receiver
        self.stellarAccount = stellarAccount
        self.currentAssetIndex = currentAssetIndex

        if let exchange = exchangeName {
            isExchangeAddress = true
            self.exchangeName = exchange
        }

        var availableBalance = ""
        if stellarAccount.assets[currentAssetIndex].assetType == AssetTypeAsString.NATIVE {
            availableBalance = stellarAccount.formattedAvailableBalance
        } else {
            availableBalance = stellarAccount.assets[currentAssetIndex].formattedBalance
        }

        navigationItem.title = "\(availableBalance) \(stellarAccount.assets[currentAssetIndex].shortCode)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        let image = UIImage(named: "close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem

        self.keyboardHolderView.delegate = self

        amountLabel.textColor = Colors.primaryDark
        exchangeHolderView.backgroundColor = Colors.red
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        sendAddressLabel.textColor = Colors.darkGray
        memoIdLabel.textColor = Colors.darkGray
        memoIdTextField.textColor = Colors.darkGray

        currencyLabel.text = stellarAccount.assets[currentAssetIndex].shortCode
        sendAddressLabel.text = "To: \(receiver)"

        memoIdTextField.inputAccessoryView = toolBar

        keyboardHolderView.update(with: KeyboardViewModel(options: KeyboardOptions.all,
                                                          buttons: KeyboardHelper.numericKeypadButtons,
                                                          bottomLeftImage: nil,
                                                          bottomRightImage: UIImage(named: "backspace"),
                                                          labelColor: Colors.primaryDark,
                                                          buttonColor: Colors.primaryDark,
                                                          backgroundColor: .clear))

        if isExchangeAddress {
            displayExchangeRequiredMessage()
        }
    }

    func displayExchangeRequiredMessage() {
        memoIdTextField.placeholder = "(Required)"
        exchangeLabelHeightConstraint.constant = 40.0

        let message = "This exchange address belongs to \(exchangeName). Please enter a memo in order to send this transaction."
        exchangeLabel.text = message
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func authenticate() {
        if let authCoordinator = self.authenticationCoordinator {
            authCoordinator.authenticate()
        } else {
            let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: true,
                                                                       presentVC: true,
                                                                       forcedStyle: nil,
                                                                       limitPinEntries: true)
            let authCoordinator = AuthenticationCoordinator(container: self, options: opts)
            authCoordinator.delegate = self

            self.authenticationCoordinator = authCoordinator

            authCoordinator.authenticate()
        }
    }

    func displayTransactionError() {
        hideHud()

        let alert = UIAlertController(title: "Transaction error", message: "There was an error processing this transaction. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func displayTransactionSuccess() {
        hideHud()

        let message = Message(title: "Transaction successful.", backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }

    func isValidSendAmount(amount: String) -> Bool {
        var totalAvailableBalance: Double = 0.00
        if stellarAccount.assets[currentAssetIndex].assetType == AssetTypeAsString.NATIVE {
            totalAvailableBalance = stellarAccount.availableBalance
        } else {
            totalAvailableBalance = Double(stellarAccount.assets[currentAssetIndex].balance)!
        }

        if let totalSendable = Double(amount) {
            return totalSendable.isZero ? false : totalSendable <= totalAvailableBalance
        }

        return false
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "Sending Payment..."
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }

    func sendPaymentAmount() {
        guard let amount = amountLabel.text, !amount.isEmpty, amount != "0" else {
            return
        }

        checkForValidAccount(account: receiver, amount: Decimal(string: amount)!)
    }
}

extension SendAmountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return true
    }
}

extension SendAmountViewController: AuthenticationCoordinatorDelegate {
    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        sendPaymentAmount()
        authenticationCoordinator = nil
    }

    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
    }
}

/**
 * Sending payment.
 */
extension SendAmountViewController {
    func checkForValidAccount(account accountId: String, amount: Decimal) {
        showHud()

        AccountOperation.getAccountDetails(accountId: accountId) { accounts in
            if accounts.count > 0 {
                self.postPaymentTransaction(accountId: accountId, amount: amount)
            } else {
                self.fundNewAccount(account: accountId, amount: amount)
            }
        }
    }

    func fundNewAccount(account accountId: String, amount: Decimal) {
        AccountOperation.createNewAccount(accountId: accountId, amount: amount) { completed in
            if completed {
                self.displayTransactionSuccess()
            } else {
                self.displayTransactionError()
            }
        }
    }

    func postPaymentTransaction(accountId: String, amount: Decimal) {
        var memoId = ""

        if let memoIdString = memoIdTextField.text {
            memoId = memoIdString
        }

        let stellarAsset = stellarAccount.assets[currentAssetIndex]

        PaymentTransactionOperation.postPayment(accountId: accountId, amount: amount, memoId: memoId, stellarAsset: stellarAsset) { completed in
            if completed {
                self.displayTransactionSuccess()
            } else {
                self.displayTransactionError()
            }
        }
    }
}

extension SendAmountViewController: KeyboardViewDelegate {
    func selected(key: KeyboardButton, action: UIEvent) {
        let containsDecimal = sendingAmount.contains(".")
        let canRemove = sendingAmount.count > 1

        switch key {
        case .number(let number) where sendingAmount == "0": sendingAmount = String(number)
        case .number(let number) where sendingAmount != "0" && number == 0: sendingAmount += String(number)
        case .number(let number) where number != 0: sendingAmount += String(number)
        case .left where !containsDecimal: sendingAmount += "."
        case .right where canRemove: sendingAmount.remove(at: sendingAmount.index(before: sendingAmount.endIndex))
        case .right where !canRemove: sendingAmount = "0"
        default: break
        }

        if containsDecimal {
            let array = sendingAmount.components(separatedBy: ".")
            if array.count > 1 {
                let decimals = array[1].count
                if decimals > decimalCountRestriction {
                    let substring = sendingAmount.prefix(array[0].count + decimalCountRestriction + decimalDotSize)
                    sendingAmount = String(substring)
                }
            }
        }

        if isValidSendAmount(amount: sendingAmount) || sendingAmount == "0" {
            amountLabel.textColor = Colors.primaryDark
        } else {
            amountLabel.textColor = Colors.red
        }

        amountLabel.text = sendingAmount.count > 0 ? sendingAmount : "0"
    }
}
