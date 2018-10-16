//
//  TradeViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import Whisper

import UIKit

enum BalanceType: Double, RawRepresentable {
    case ten = 0.1
    case twentyFive = 0.25
    case fifty = 0.50
    case seventyFive = 0.75
    case hundred = 1.0

    var decimal: Decimal {
        return Decimal(self.rawValue)
    }

    static var all: [BalanceType] {
        return [.ten, .twentyFive, .fifty, .seventyFive, .hundred]
    }
}

enum TradeType: Int {
    case market
    case limit

    static var all: [TradeType] {
        return [.market, .limit]
    }
}

protocol TradeViewControllerDelegate: AnyObject {
    func getOrderBook(sellingAsset: StellarAsset, buyingAsset: StellarAsset)
    func displayNoAssetOverlay()
    func hideNoAssetOverlay()
    func update(stellarAccount: StellarAccount)
    func displayAddAssetForTrade()
}

//swiftlint:disable file_length type_body_length
class TradeViewController: UIViewController {
    @IBOutlet var addAssetButton: UIButton!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var buttonHolderView: UIView!
    @IBOutlet var marketLabelHolderView: UIView!
    @IBOutlet var marketLabel: UILabel!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var tradeFromView: UIView!
    @IBOutlet var tradeToView: UIView!
    @IBOutlet var tradeFromButton: UIButton!
    @IBOutlet var tradeToButton: UIButton!
    @IBOutlet var tradeFromTextField: UITextField!
    @IBOutlet var tradeToTextField: UITextField!
    @IBOutlet var tradeFromSelectorTextField: UITextField!
    @IBOutlet var tradeToSelectorTextField: UITextField!
    @IBOutlet var tradeFromInputAccessoryView: UIView!
    @IBOutlet var tradeToInputAccessoryView: UIView!
    @IBOutlet var tradeFromSelectorAccessoryInputView: UIView!
    @IBOutlet var tradeToSelectorAccessoryInputView: UIView!

    let tradeFromPickerView = UIPickerView()
    let tradeToPickerView = UIPickerView()
    var stellarAccount = StellarAccount()
    var toAssets: [StellarAsset] = []
    var fromAsset: StellarAsset!
    var toAsset: StellarAsset!
    var currentTradeType: TradeType = .market
    var currentMarketPrice: Double = 0.0

    weak var delegate: TradeViewControllerDelegate?

    @IBAction func setBalanceAmount(sender: UIButton) {
        guard var balance = Decimal(string: fromAsset.balance) else {
            return
        }

        if fromAsset.isNative {
            balance = Decimal(stellarAccount.availableBalance)
        }

        let multiplier = BalanceType.all[sender.tag].decimal
        let scaledBalance = balance * multiplier

        let value = scaledBalance.displayFormattedString
        tradeFromTextField.text = value

        if currentTradeType == .market {
            setCalculatedMarketPrice(tradeFromText: value)
        }
    }

    @IBAction func addAsset() {
        delegate?.displayAddAssetForTrade()
    }

    @IBAction func tradeTypeSwitched(sender: UISegmentedControl) {
        currentTradeType = TradeType.all[sender.selectedSegmentIndex]
        setTradeViews()
    }

    @IBAction func tradeFromTextFieldDidChange() {
        if currentTradeType == .market {
            guard let tradeFromText = tradeFromTextField.text, !tradeFromText.isEmpty else {
                tradeToTextField.text = ""
                return
            }

            setCalculatedMarketPrice(tradeFromText: tradeFromText)
        }
    }

    @IBAction func submitTrade() {
        guard let tradeFromAmount = tradeFromTextField.text, !tradeFromAmount.isEmpty else {
            tradeFromTextField.shake()
            return
        }

        guard let tradeToAmount = tradeToTextField.text, !tradeToAmount.isEmpty else {
            tradeToTextField.shake()
            return
        }

        guard let denominator = Decimal(string: tradeFromAmount) else {
            tradeFromTextField.shake()
            return
        }

        guard let numerator = Decimal(string: tradeToAmount) else {
            tradeToTextField.shake()
            return
        }

        dismissKeyboard()

        let alertMessage = String(format: "SUBMIT_TRADE_FORMAT".localized(),
                                  tradeFromAmount, fromAsset.shortCode, tradeToAmount, toAsset.shortCode)

        let cancelAction = UIAlertAction(title: "CANCEL_ACTION".localized(), style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "TRADE_TITLE".localized(), style: .default, handler: { _ in
            self.showHud()

            TradeOperation.postTrade(tradePrice: (numerator: numerator, denominator: denominator),
                                     assets: (selling: self.fromAsset, buying: self.toAsset),
                                     type: self.currentTradeType) { completed in
                self.hideHud()
                self.getOrderBook()
                self.updateBalance()

                if !completed {
                    self.displayTradeError(message: "TRADE_ERROR_MESSAGE".localized())
                } else {
                    self.tradeFromTextField.text = ""
                    self.tradeToTextField.text = ""
                    self.displayTradeSuccess()
                }
            }
        })

        let alert = UIAlertController(title: "SUBMIT_TRADE_TITLE".localized(),
                                      message: alertMessage,
                                      preferredStyle: .alert)

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }

    func displayTradeError(message: String) {
        let alert = UIAlertController(title: "TRADE_ERROR_TITLE".localized(),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(),
                                      style: .default,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func displayTradeSuccess() {
        let message = Message(title: "TRADE_SUBMITTED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)
        }
    }

    @IBAction func tradeFromSelected() {
        tradeFromSelectorTextField.becomeFirstResponder()
    }

    @IBAction func tradeToSelected() {
        tradeToSelectorTextField.becomeFirstResponder()
    }

    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAccountDetails()
    }

    func setupView() {
        tradeFromView.layer.borderWidth = 0.5
        tradeFromView.layer.borderColor = Colors.red.cgColor

        tradeToView.layer.borderWidth = 0.5
        tradeToView.layer.borderColor = Colors.green.cgColor

        balanceLabel.textColor = Colors.darkGray
        arrowImageView.tintColor = Colors.lightGray
        addAssetButton.backgroundColor = Colors.primaryDark
        marketLabelHolderView.backgroundColor = Colors.lightBackground
        segmentControl.tintColor = Colors.lightGray
        tableview.backgroundColor = Colors.lightBackground
        tradeFromButton.backgroundColor = Colors.red
        tradeToButton.backgroundColor = Colors.green
        tradeFromTextField.textColor = Colors.darkGray
        tradeToTextField.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: .selected)

        for subview in buttonHolderView.subviews {
            if let button = subview as? UIButton {
                button.backgroundColor = Colors.lightGrayTransparent
                button.setTitleColor(Colors.darkGray, for: .normal)
            }
        }

        tradeFromPickerView.dataSource = self
        tradeFromPickerView.delegate = self

        tradeToPickerView.dataSource = self
        tradeToPickerView.delegate = self

        tradeFromTextField.inputAccessoryView = tradeFromInputAccessoryView
        tradeToTextField.inputAccessoryView = tradeToInputAccessoryView
        tradeFromSelectorTextField.inputAccessoryView = tradeFromSelectorAccessoryInputView
        tradeToSelectorTextField.inputAccessoryView = tradeToSelectorAccessoryInputView

        tradeFromSelectorTextField.inputView = tradeFromPickerView
        tradeToSelectorTextField.inputView = tradeToPickerView

        setTradeViews()
    }

    func setTradeViews() {
        switch currentTradeType {
        case .market:
            tradeToTextField.isEnabled = false
            tradeToView.backgroundColor = Colors.lightBackground
            if let tradeFromText = tradeFromTextField.text {
                setCalculatedMarketPrice(tradeFromText: tradeFromText)
            }
            marketLabel.text = "TRADE_MARKET_INFO".localized()
        case .limit:
            tradeToTextField.isEnabled = true
            tradeToView.backgroundColor = Colors.white
            marketLabel.text = ""
        }
    }

    func setTradeSelectors(fromAsset: StellarAsset?, toAsset: StellarAsset?) {
        if let selectedFromAsset = fromAsset {
            self.fromAsset = selectedFromAsset
            setTradeFromSelector()
            getOrderBook()
            return
        }

        if let selectedToAsset = toAsset {
            self.toAsset = selectedToAsset
            setTradeToSelector()
            getOrderBook()
            return
        }
    }

    func getOrderBook() {
        if let sellingAsset = fromAsset, let buyingAsset = toAsset {
            delegate?.getOrderBook(sellingAsset: sellingAsset, buyingAsset: buyingAsset)
        }
    }

    func setTradeFromSelector() {
        guard let removableIndex = self.stellarAccount.assets.index(of: fromAsset) else {
            return
        }

        var formatString = "TRADE_BALANCE_FORMAT"
        var balanceAmount = fromAsset.balance.decimalFormatted

        if fromAsset.isNative {
            formatString = "TRADE_BALANCE_AVAILABLE_FORMAT"
            balanceAmount = stellarAccount.availableBalance.displayFormattedString
        }

        tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
        balanceLabel.text = String(format: formatString.localized(), balanceAmount, fromAsset.shortCode)

        toAssets = self.stellarAccount.assets
        toAssets.remove(at: removableIndex)
        toAsset = toAssets[0]
        tradeToButton.setTitle(toAsset.shortCode, for: .normal)

        tradeFromPickerView.reloadAllComponents()
        tradeToPickerView.reloadAllComponents()
        tradeToPickerView.selectRow(0, inComponent: 0, animated: false)
    }

    func setTradeToSelector() {
        if let fromButtonText = tradeFromButton.titleLabel?.text, !fromButtonText.elementsEqual(toAsset.shortCode) {
            tradeToButton.setTitle(toAsset.shortCode, for: .normal)
            return
        }

        var toAssetToRemove: StellarAsset!

        for asset in self.stellarAccount.assets where tradeFromButton.titleLabel?.text != asset.shortCode {
            fromAsset = asset
            tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
            balanceLabel.text = "\(fromAsset.balance.decimalFormatted) \(fromAsset.shortCode)"
            toAssetToRemove = fromAsset
        }

        guard let removableToAsset = toAssetToRemove,
            let removableIndex = self.stellarAccount.assets.index(of: removableToAsset) else {
            return
        }

        tradeToButton.setTitle(toAsset.shortCode, for: .normal)

        toAssets = self.stellarAccount.assets
        toAssets.remove(at: removableIndex)

        tradeFromPickerView.reloadAllComponents()
        tradeToPickerView.reloadAllComponents()

        tradeFromPickerView.selectRow(0, inComponent: 0, animated: false)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "TRADE_SUBMITTING_MESSAGE".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }

    func setMarketPrice(orderBook: OrderbookResponse) {
        if orderBook.bids.count > 0 {
            guard let bestPrice = Double(orderBook.bids[0].price) else {
                return
            }

            currentMarketPrice = bestPrice
        }

        if let tradeFromText = tradeFromTextField.text {
            setCalculatedMarketPrice(tradeFromText: tradeFromText)
        }
    }

    func setCalculatedMarketPrice(tradeFromText: String) {
        guard let tradeFromValue = Double(tradeFromText) else {
            return
        }

        let toValue = tradeFromValue * currentMarketPrice
        tradeToTextField.text = toValue.displayFormattedString
    }
}

extension TradeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == tradeFromPickerView {
            return stellarAccount.assets.count
        }
        return toAssets.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == tradeFromPickerView {
            setTradeSelectors(fromAsset: stellarAccount.assets[row], toAsset: nil)
            return
        }
        setTradeSelectors(fromAsset: nil, toAsset: toAssets[row])
    }
}

extension TradeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let formatString = "%@ (%@)"
        if pickerView == tradeFromPickerView {
            return String(format: formatString,
                          Assets.displayTitle(shortCode: stellarAccount.assets[row].shortCode),
                          stellarAccount.assets[row].shortCode)
        }

        return String(format: formatString,
               Assets.displayTitle(shortCode: toAssets[row].shortCode),
               toAssets[row].shortCode)
    }
}

/*
 * Operations
 */
extension TradeViewController {
    func getAccountDetails() {
        guard let accountId = KeychainHelper.accountId else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            if !responseAccounts.isEmpty && responseAccounts[0].assets.count > 1 {
                self.stellarAccount = responseAccounts[0]
                if self.fromAsset == nil {
                    self.setTradeSelectors(fromAsset: self.stellarAccount.assets[0], toAsset: nil)
                }

                self.delegate?.update(stellarAccount: self.stellarAccount)
                self.delegate?.hideNoAssetOverlay()
            } else {
                let account = StellarAccount()
                account.accountId = accountId

                let stellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                                assetCode: nil,
                                                assetIssuer: nil,
                                                balance: "0.0000")

                account.assets.removeAll()
                account.assets.append(stellarAsset)

                self.stellarAccount = account
                self.delegate?.update(stellarAccount: account)
                self.delegate?.displayNoAssetOverlay()
            }
        }
    }

    func updateBalance() {
        guard let accountId = KeychainHelper.accountId else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            if !responseAccounts.isEmpty && responseAccounts[0].assets.count > 1 {
                self.stellarAccount = responseAccounts[0]
                for asset in self.stellarAccount.assets where asset == self.fromAsset {
                    self.fromAsset = asset
                    var balance = asset.balance
                    var labelFormat = "TRADE_BALANCE_FORMAT".localized()

                    if asset.isNative {
                        labelFormat = "TRADE_BALANCE_AVAILABLE_FORMAT".localized()
                        balance = self.stellarAccount.availableBalance.displayFormattedString
                    }

                    self.balanceLabel.text = String(format: labelFormat, balance, asset.shortCode)
                    break
                }
            }
        }
    }
}
//swiftlint:enable file_length type_body_length
