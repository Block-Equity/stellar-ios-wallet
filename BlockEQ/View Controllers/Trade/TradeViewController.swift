//
//  TradeViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

protocol TradeViewControllerDelegate: AnyObject {
    func getOrderBook(for pair: StellarAssetPair)
    func requestedRefresh()
    func availableBalance(for asset: StellarAsset) -> Decimal
    func scaledBalance(type: TradeViewController.BalanceType) -> Decimal
    func requestTrade(type: StellarTradeOfferData.TradeType,
                      toAmount: String,
                      fromAmount: String,
                      numerator: Decimal,
                      denominator: Decimal)
}

extension TradeViewController {
    enum BalanceType: Double, RawRepresentable, CaseIterable {
        case ten = 0.1
        case twentyFive = 0.25
        case fifty = 0.50
        case seventyFive = 0.75
        case hundred = 1.0

        var decimal: Decimal {
            return Decimal(self.rawValue)
        }
    }

    enum TradeType: Int {
        case market
        case limit

        static var all: [TradeType] {
            return [.market, .limit]
        }
    }

    enum TradeField {
        case fromAsset
        case toAsset
        case firstTimeAdd
    }
}

final class TradeViewController: UIViewController {
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
    @IBOutlet var tradeTextInputAccessoryView: UIView!

    weak var delegate: TradeViewControllerDelegate?
    weak var assetDelegate: TradeAssetListDisplayable?

    var currentTradeType: StellarTradeOfferData.TradeType = .market

    var currentMarketPrice: Decimal = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.requestedRefresh()
    }

    func setupView() {
        tradeFromView.layer.borderWidth = 0.5
        tradeFromView.layer.borderColor = Colors.red.cgColor

        tradeToView.layer.borderWidth = 0.5
        tradeToView.layer.borderColor = Colors.green.cgColor

        balanceLabel.textColor = Colors.darkGray
        arrowImageView.tintColor = Colors.lightGray
        marketLabelHolderView.backgroundColor = Colors.lightBackground
        segmentControl.tintColor = Colors.lightGray
        tableview.backgroundColor = Colors.lightBackground
        tradeFromButton.backgroundColor = Colors.red
        tradeToButton.backgroundColor = Colors.green
        tradeFromTextField.textColor = Colors.darkGray
        tradeToTextField.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground

        tradeFromTextField.inputAccessoryView = tradeTextInputAccessoryView
        tradeToTextField.inputAccessoryView = tradeTextInputAccessoryView

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

        setTradeViews()
    }

    func refreshView(pair: StellarAssetPair?) {
        guard self.isViewLoaded else {
            return
        }

        setTradeSelectors(assetPair: pair)
        updateBalances(assetPair: pair)

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

    func setTradeSelectors(assetPair: StellarAssetPair?) {
        if let fromAsset = assetPair?.selling, let balance = delegate?.availableBalance(for: fromAsset) {
            let formatString = fromAsset.isNative ? "TRADE_BALANCE_AVAILABLE_FORMAT" : "TRADE_BALANCE_FORMAT"
            let balanceString = balance.tradeFormattedString
            tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
            balanceLabel.text = String(format: formatString.localized(), balanceString, fromAsset.shortCode)
        }

        if let toAsset = assetPair?.buying {
            tradeToButton.setTitle(toAsset.shortCode, for: .normal)
        }
    }

    func updateBalances(assetPair: StellarAssetPair?) {
        if let fromAsset = assetPair?.selling, let balance = delegate?.availableBalance(for: fromAsset) {
            let balanceString = balance.tradeFormattedString
            let labelFormat = fromAsset.isNative ? "TRADE_BALANCE_AVAILABLE_FORMAT" : "TRADE_BALANCE_FORMAT"
            self.balanceLabel.text = String(format: labelFormat.localized(), balanceString, fromAsset.shortCode)
        }
    }

    func setMarketPrice(orderbook: StellarOrderbook, assetPair: StellarAssetPair?) {
        guard let bestPrice = orderbook.bestPrice else {
            return
        }

        currentMarketPrice = bestPrice
        self.refreshView(pair: assetPair)
    }

    func setCalculatedMarketPrice(tradeFromText: String) {
        guard let tradeFromValue = Decimal(string: tradeFromText) else {
            return
        }

        let toValue = tradeFromValue * currentMarketPrice
        tradeToTextField.text = toValue.tradeFormattedString
    }

    func clearTradeFields() {
        self.tradeFromTextField.text = ""
        self.tradeToTextField.text = ""
    }
}

// MARK: - IBActions
extension TradeViewController {
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func tradeFromSelected() {
        assetDelegate?.requestedDisplayAssetList(for: .fromAsset)
    }

    @IBAction func tradeToSelected() {
        assetDelegate?.requestedDisplayAssetList(for: .toAsset)
    }

    @IBAction func setBalanceAmount(sender: UIButton) {
        let type = BalanceType.allCases[sender.tag]

        guard let scaledBalance = delegate?.scaledBalance(type: type) else { return }
        let value = scaledBalance.tradeFormattedString
        tradeFromTextField.text = value

        if currentTradeType == .market {
            setCalculatedMarketPrice(tradeFromText: value)
        }
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

        delegate?.requestTrade(type: currentTradeType,
                               toAmount: tradeToAmount,
                               fromAmount: tradeFromAmount,
                               numerator: numerator,
                               denominator: denominator)
    }
}

// MARK: - FrameworkErrorPresentable
extension TradeViewController: FrameworkErrorPresentable { }
