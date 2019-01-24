//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol SendAmountViewControllerDelegate: AnyObject {
    func validateSendAmount(amount: String) -> Bool
    func requestedSendAmount(_ viewController: SendAmountViewController, amount: Decimal, memo: String?)
    func cancelledSendAmount(_ viewController: SendAmountViewController)
}

extension SendAmountViewController {
    struct ViewModel {
        var destinationAddress: String
        var exchange: Exchange?
        var availableSendBalance: Decimal
        var assetShortCode: String
    }
}

final class SendAmountViewController: UIViewController {
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

    weak var delegate: SendAmountViewControllerDelegate?

    var sendingAmount: String = "0"
    var currentAsset: StellarAsset?
    var requiresExchangeAddress: Bool = false
    var exchangeName: String = ""
    var availableAmount = Decimal(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        keyboardHolderView.delegate = self

        amountLabel.textColor = Colors.primaryDark
        exchangeHolderView.backgroundColor = Colors.red
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        sendAddressLabel.textColor = Colors.darkGray
        memoIdLabel.textColor = Colors.darkGray
        memoIdTextField.textColor = Colors.darkGray

        currencyLabel.text = currentAsset?.shortCode
        memoIdTextField.inputAccessoryView = toolBar

        keyboardHolderView.update(with: KeyboardViewModel(options: KeyboardOptions.all,
                                                          buttons: KeyboardHelper.numericKeypadButtons,
                                                          bottomLeftImage: nil,
                                                          bottomRightImage: UIImage(named: "backspace"),
                                                          labelColor: Colors.primaryDark,
                                                          buttonColor: Colors.primaryDark,
                                                          backgroundColor: .clear))
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func update(with viewModel: ViewModel) {
        availableAmount = viewModel.availableSendBalance

        title = String(format: "TRADE_BALANCE_FORMAT".localized(),
                       viewModel.availableSendBalance.tradeFormattedString,
                       viewModel.assetShortCode)

        sendAddressLabel.text = String(format: "SEND_TO_FORMAT".localized(), viewModel.destinationAddress)

        if let exchange = viewModel.exchange {
            requiresExchangeAddress = true
            exchangeName = exchange.name
            memoIdTextField.placeholder = "REQUIRED_PLACEHOLDER".localized()
            exchangeLabelHeightConstraint.constant = 40.0
            exchangeLabel.text = String(format: "EXCHANGE_ADDRESS_PROMPT_FORMAT".localized(), exchangeName)
        }
    }
}

// MARK: - IBActions
extension SendAmountViewController {
    @IBAction func sendPayment() {
        guard let amountText = amountLabel.text, !amountText.isEmpty, let amount = Decimal(string: amountText) else {
            amountLabel.shake()
            return
        }

        guard delegate?.validateSendAmount(amount: amountText) == true else {
            amountLabel.shake()
            return
        }

        if requiresExchangeAddress {
            guard let memo = memoIdTextField.text, !memo.isEmpty else {
                memoIdLabel.shake()
                return
            }
        }

        delegate?.requestedSendAmount(self, amount: amount, memo: memoIdTextField.text)
    }

    @IBAction func clearTextfield() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SendAmountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - KeyboardViewDelegate
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

        if delegate?.validateSendAmount(amount: sendingAmount) == true || sendingAmount == "0" {
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
