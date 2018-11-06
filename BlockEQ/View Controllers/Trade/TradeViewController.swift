//
//  TradeViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService
import stellarsdk
import Whisper

//swiftlint:disable file_length
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

protocol TradeViewControllerDelegate: AnyObject {
    func getOrderBook(for pair: StellarAssetPair)
    func postTrade(data: StellarTradeOfferData)
    func displayAddAssetForTrade()
}

extension TradeViewController {
    enum TradeType: Int {
        case market
        case limit

        static var all: [TradeType] {
            return [.market, .limit]
        }
    }
}

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
    var stellarAccount: StellarAccount?

    var fromDataSource: TradePickerDataSource?
    var toDataSource: TradePickerDataSource?

    var currentTradeType: StellarTradeOfferData.TradeType = .market
    var currentMarketPrice: Decimal = 0.0

    var fromAsset: StellarAsset? {
        return fromDataSource?.selected
    }

    var toAsset: StellarAsset? {
        return toDataSource?.selected
    }

    var assetPair: StellarAssetPair? {
        if let buyingAsset = toAsset, let sellingAsset = fromAsset {
            return StellarAssetPair(buying: buyingAsset, selling: sellingAsset)
        }

        return nil
    }

    weak var delegate: TradeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
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

        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let deselectedTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGray]
        segmentControl.setTitleTextAttributes(deselectedTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentControl.tintColor = Colors.primaryDark

        for subview in buttonHolderView.subviews {
            if let button = subview as? UIButton {
                button.backgroundColor = Colors.lightGrayTransparent
                button.setTitleColor(Colors.darkGray, for: .normal)
            }
        }

        tradeFromTextField.inputAccessoryView = tradeFromInputAccessoryView
        tradeToTextField.inputAccessoryView = tradeToInputAccessoryView
        tradeFromSelectorTextField.inputAccessoryView = tradeFromSelectorAccessoryInputView
        tradeToSelectorTextField.inputAccessoryView = tradeToSelectorAccessoryInputView

        tradeFromSelectorTextField.inputView = tradeFromPickerView
        tradeToSelectorTextField.inputView = tradeToPickerView

        setTradeViews()
    }

    func refreshView() {
        guard self.isViewLoaded else {
            return
        }

        setTradeSelectors()
        updateBalances()

        if self.currentTradeType == .market, let tradeFromText = tradeFromTextField.text {
            setCalculatedMarketPrice(tradeFromText: tradeFromText)
        }
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

    func setTradeSelectors() {
        guard let account = self.stellarAccount else { return }

        var formatString = "TRADE_BALANCE_FORMAT"
        var balanceAmount: String

        if let fromAsset = fromAsset {
            balanceAmount = fromAsset.balance.displayFormatted

            if fromAsset.isNative {
                formatString = "TRADE_BALANCE_AVAILABLE_FORMAT"
                balanceAmount = account.availableBalance.displayFormattedString
            }

            tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
            balanceLabel.text = String(format: formatString.localized(), balanceAmount, fromAsset.shortCode)
        }

        if let toAsset = toAsset {
            tradeToButton.setTitle(toAsset.shortCode, for: .normal)
        }
    }

    func updateBalances() {
        guard let account = self.stellarAccount else { return }

        if let asset = account.assets.first(where: { $0 == fromAsset }) {
            var balance = asset.balance
            var labelFormat = "TRADE_BALANCE_FORMAT".localized()

            if asset.isNative {
                labelFormat = "TRADE_BALANCE_AVAILABLE_FORMAT".localized()
                balance = account.availableBalance.displayFormattedString
            }

            self.balanceLabel.text = String(format: labelFormat, balance, asset.shortCode)
        }
    }

    func setMarketPrice(orderbook: StellarOrderbook) {
        guard let bestPrice = orderbook.bestPrice else {
            return
        }

        currentMarketPrice = bestPrice
        self.refreshView()
    }

    func setCalculatedMarketPrice(tradeFromText: String) {
        guard let tradeFromValue = Decimal(string: tradeFromText) else {
            return
        }

        let toValue = tradeFromValue * currentMarketPrice
        tradeToTextField.text = toValue.displayFormattedString
    }

    func buildFromDataSource(with selectedAsset: StellarAsset?) {
        guard let account = self.stellarAccount else { return }

        let selectedFromAsset = selectedAsset ?? account.assets.first
        let fromDataSource = TradePickerDataSource(assets: account.assets,
                                                   selected: selectedFromAsset,
                                                   excluding: nil)
        fromDataSource.delegate = self

        self.tradeFromPickerView.dataSource = fromDataSource
        self.tradeFromPickerView.delegate = fromDataSource
        self.fromDataSource = fromDataSource

        tradeFromPickerView.reloadAllComponents()
    }

    func buildToDataSource(with selectedAsset: StellarAsset?) {
        guard let account = self.stellarAccount else { return }

        let selectedFromAsset = self.fromAsset

        let selectedToAsset = firstAssetExcluding(selectedFromAsset, in: account)
        let toDataSource = TradePickerDataSource(assets: account.assets,
                                                 selected: selectedToAsset,
                                                 excluding: selectedFromAsset)
        toDataSource.delegate = self

        self.tradeToPickerView.dataSource = toDataSource
        self.tradeToPickerView.delegate = toDataSource
        self.toDataSource = toDataSource

        tradeToPickerView.reloadAllComponents()
    }

    func firstAssetExcluding(_ asset: StellarAsset?, in account: StellarAccount) -> StellarAsset? {
        let nonSelectedAssets = account.assets.filter { $0 != asset }
        return nonSelectedAssets.first
    }
}

extension TradeViewController: AccountUpdatable {
    func update(account: StellarAccount) {
        self.stellarAccount = account

        if let fromAsset = fromAsset {
            fromDataSource?.selected = account.indexedAssets[fromAsset.shortCode]
        }

        if let toAsset = toAsset {
            toDataSource?.selected = account.indexedAssets[toAsset.shortCode]
        }

        buildFromDataSource(with: fromAsset)
        buildToDataSource(with: toAsset)

        self.refreshView()
    }
}

// MARK: - TradePickerDataSource
extension TradeViewController: TradePickerDataSourceDelegate {
    func selectedAsset(_ pickerView: UIPickerView, asset: StellarAsset?) {
        tradeFromTextField.text = ""
        tradeToTextField.text = ""

        if pickerView == tradeFromPickerView {
            buildFromDataSource(with: asset)
            buildToDataSource(with: nil)
            setTradeSelectors()
            tradeToPickerView.selectRow(0, inComponent: 0, animated: false)
        } else {
            buildFromDataSource(with: nil)
            buildToDataSource(with: asset)
            setTradeSelectors()
            tradeFromPickerView.selectRow(0, inComponent: 0, animated: false)
        }

        getOrderBook()
    }
}

// MARK: - Prompts
extension TradeViewController {
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "TRADE_SUBMITTING_MESSAGE".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }

    func displayTradeSuccess() {
        hideHud()

        self.tradeFromTextField.text = ""
        self.tradeToTextField.text = ""

        let message = Message(title: "TRADE_SUBMITTED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)
        }
    }

    func displayTradeError() {
        self.hideHud()

        let alert = UIAlertController(title: "TRADE_ERROR_TITLE".localized(),
                                      message: "TRADE_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(),
                                      style: .default,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - IBActions
extension TradeViewController {
    @IBAction func tradeFromSelected() {
        tradeFromSelectorTextField.becomeFirstResponder()
    }

    @IBAction func tradeToSelected() {
        tradeToSelectorTextField.becomeFirstResponder()
    }

    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func setBalanceAmount(sender: UIButton) {
        guard let account = self.stellarAccount, let fromAsset = self.fromAsset,
            var balance = Decimal(string: fromAsset.balance) else {
                return
        }

        if fromAsset.isNative {
            balance = account.availableBalance
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
        currentTradeType = StellarTradeOfferData.TradeType.all[sender.selectedSegmentIndex]
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

        guard let fromAsset = self.fromAsset, let toAsset = self.toAsset else { return }

        let alertMessage = String(format: "SUBMIT_TRADE_FORMAT".localized(),
                                  tradeFromAmount, fromAsset.shortCode, tradeToAmount, toAsset.shortCode)

        let cancelAction = UIAlertAction(title: "CANCEL_ACTION".localized(), style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "TRADE_TITLE".localized(), style: .default, handler: { _ in
            self.showHud()

            let price = Price(numerator: numerator, denominator: denominator)
            let pair = StellarAssetPair(buying: toAsset, selling: fromAsset)
            let offerData = StellarTradeOfferData(type: self.currentTradeType,
                                                  assetPair: pair,
                                                  price: price,
                                                  numerator: numerator,
                                                  denominator: denominator,
                                                  offerId: nil)

            self.delegate?.postTrade(data: offerData)
        })

        let alert = UIAlertController(title: "SUBMIT_TRADE_TITLE".localized(),
                                      message: alertMessage,
                                      preferredStyle: .alert)

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Order Book
extension TradeViewController {
    func getOrderBook() {
        if let sellingAsset = fromAsset, let buyingAsset = toAsset {
            let assetPair = StellarAssetPair(buying: buyingAsset, selling: sellingAsset)
            delegate?.getOrderBook(for: assetPair)
        }
    }
}
//swiftlint:enable file_length
