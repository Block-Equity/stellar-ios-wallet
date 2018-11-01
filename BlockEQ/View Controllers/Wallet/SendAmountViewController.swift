//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Whisper
import stellarsdk
import StellarAccountService

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

    var receiver: StellarAddress
    var sendingAmount: String = "0"
    var stellarAccount: StellarAccount
    var currentAsset: StellarAsset?
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

    init(stellarAccount: StellarAccount, currentAsset: StellarAsset, receiver: StellarAddress, exchangeName: String?) {
        self.receiver = receiver
        self.stellarAccount = stellarAccount
        self.currentAsset = currentAsset

        super.init(nibName: String(describing: SendAmountViewController.self), bundle: nil)

        if let exchange = exchangeName {
            isExchangeAddress = true
            self.exchangeName = exchange
        }
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

        guard let asset = self.currentAsset else { return }

        var availableBalance = ""
        if asset.assetType == AssetTypeAsString.NATIVE {
            availableBalance = stellarAccount.formattedAvailableBalance
        } else {
            availableBalance = asset.balance.displayFormatted
        }

        navigationItem.title = "\(availableBalance) \(asset.shortCode)"
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        self.keyboardHolderView.delegate = self

        amountLabel.textColor = Colors.primaryDark
        exchangeHolderView.backgroundColor = Colors.red
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        sendAddressLabel.textColor = Colors.darkGray
        memoIdLabel.textColor = Colors.darkGray
        memoIdTextField.textColor = Colors.darkGray

        currencyLabel.text = currentAsset?.shortCode
        sendAddressLabel.text = String(format: "SEND_TO_FORMAT".localized(), (receiver.string))

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
        memoIdTextField.placeholder = "REQUIRED_PLACEHOLDER".localized()
        exchangeLabelHeightConstraint.constant = 40.0
        exchangeLabel.text = String(format: "EXCHANGE_ADDRESS_PROMPT_FORMAT".localized(), exchangeName)
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

        let alert = UIAlertController(title: "TRANSACTION_ERROR_TITLE".localized(),
                                      message: "TRANSACTION_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(),
                                      style: .default,
                                      handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func displayTransactionSuccess() {
        hideHud()

        let message = Message(title: "TRANSACTION_SUCCESS".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }

    func isValidSendAmount(amount: String) -> Bool {

        guard let asset = self.currentAsset else { return false }

        var totalAvailableBalance: Double = 0.00
        if asset.assetType == AssetTypeAsString.NATIVE {
            totalAvailableBalance = stellarAccount.availableBalance
        } else {
            totalAvailableBalance = Double(asset.balance)!
        }

        if let totalSendable = Double(amount) {
            return totalSendable.isZero ? false : totalSendable <= totalAvailableBalance
        }

        return false
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "SENDING_PAYMENT".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }

    func sendPaymentAmount() {
        guard let amountString = amountLabel.text, let amount = Decimal(string: amountString), !amount.isZero else {
            amountLabel.shake()
            return
        }

        guard let asset = currentAsset else {
            return
        }

        showHud()

        let paymentData = StellarPaymentData(address: receiver,
                                             amount: amount,
                                             memo: memoIdTextField.text,
                                             asset: asset)

        self.stellarAccount.sendAmount(data: paymentData, delegate: self)
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

        sendingAmount = restrictDecimalPlaces(amount: sendingAmount)

        if isValidSendAmount(amount: sendingAmount) || sendingAmount == "0" {
            amountLabel.textColor = Colors.primaryDark
        } else {
            amountLabel.textColor = Colors.red
        }

        amountLabel.text = sendingAmount.count > 0 ? sendingAmount : "0"
    }

    func restrictDecimalPlaces(amount: String) -> String {
        guard sendingAmount.contains(".") else { return amount }

        let array = sendingAmount.components(separatedBy: ".")
        if array.count > 1 {
            let decimals = array[1].count
            if decimals > decimalCountRestriction {
                return String(sendingAmount.prefix(array[0].count + decimalCountRestriction + decimalDotSize))
            }
        }

        return amount
    }
}

extension SendAmountViewController: SendAmountResponseDelegate {
    func sentAmount(destination: StellarAddress) {
        self.displayTransactionSuccess()
    }

    func failed(error: Error) {
        self.displayTransactionError()
    }
}
