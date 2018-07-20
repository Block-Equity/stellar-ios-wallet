//
//  TradeViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

enum BalanceType: Int {
    case ten
    case twentyFive
    case fifty
    case seventyFive
    case hundred
    
    var value: Float {
        switch self {
        case .ten: return 0.10
        case .twentyFive: return 0.25
        case .fifty: return 0.50
        case .seventyFive: return 0.75
        case .hundred: return 1
        }
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
}

class TradeViewController: UIViewController {
    
    @IBOutlet var addAssetButton: UIButton!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var buttonHolderView: UIView!
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
    var currentMarketPrice: Float = 0.0
    
    weak var delegate: TradeViewControllerDelegate?
    
    @IBAction func setBalanceAmount(sender: UIButton) {
        guard let floatBalance = Float(fromAsset.balance) else {
            return
        }
        tradeFromTextField.text = String(floatBalance * BalanceType.all[sender.tag].value).decimalFormatted()
    }
    
    @IBAction func addAsset() {
        
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
        // TODO: Delegate back to the coordinator indicating we need to present a modal pin challenge
        /*
        if PinOptionHelper.check(.pinOnTrade) {
            let alert = UIAlertController(title: "Implement PIN", message: "Implement PIN challenge here", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }*/

        guard let tradeFromAmount = tradeFromTextField.text, !tradeFromAmount.isEmpty else {
            tradeFromTextField.shake()
            return
        }
        
        guard let tradeToAmount = tradeToTextField.text, !tradeToAmount.isEmpty else {
            tradeToTextField.shake()
            return
        }
        
        dismissKeyboard()
        showHud()
        
        TradeOperation.postTrade(amount: Decimal(string: tradeFromAmount)!, numerator: Int(Float(tradeToAmount)! * 1000000), denominator: Int(Float(tradeFromAmount)! * 1000000), sellingAsset: fromAsset, buyingAsset: toAsset, offerId: 0) { completed in
            self.hideHud()
            self.getOrderBook()
            
            if !completed {
                let alert = UIAlertController(title: "Trade Error", message: "Sorry your order could not be processed at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.tradeFromTextField.text = ""
                self.tradeToTextField.text = ""
            }
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
        segmentControl.tintColor = Colors.lightGray
        tableview.backgroundColor = Colors.lightBackground
        tradeFromButton.backgroundColor = Colors.red
        tradeToButton.backgroundColor = Colors.green
        tradeFromTextField.textColor = Colors.darkGray
        tradeToTextField.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground
        
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
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
            
            break
        case .limit:
            tradeToTextField.isEnabled = true
            tradeToView.backgroundColor = Colors.white
            break
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
        if let toButtonText = tradeToButton.titleLabel?.text, !toButtonText.elementsEqual(fromAsset.shortCode) {
            tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
            balanceLabel.text = "\(fromAsset.balance.decimalFormatted()) \(fromAsset.shortCode)"
            return
        }
        
        guard let removableIndex = self.stellarAccount.assets.index(of: fromAsset) else {
            return
        }
        
        tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
        balanceLabel.text = "\(fromAsset.balance.decimalFormatted()) \(fromAsset.shortCode)"
        
        toAssets = self.stellarAccount.assets
        toAssets.remove(at: removableIndex)
        toAsset = toAssets[0]
        tradeToButton.setTitle(toAsset.shortCode, for: .normal)
        
        tradeFromPickerView.reloadAllComponents()
        tradeToPickerView.reloadAllComponents()
        tradeToPickerView.selectRow(0, inComponent: 0, animated: false)
        
        return
    }
    
    func setTradeToSelector() {
        if let fromButtonText = tradeFromButton.titleLabel?.text, !fromButtonText.elementsEqual(toAsset.shortCode) {
            tradeToButton.setTitle(toAsset.shortCode, for: .normal)
            return
        }
        
        var toAssetToRemove: StellarAsset!
        
        for asset in self.stellarAccount.assets {
            if tradeFromButton.titleLabel?.text != asset.shortCode {
                fromAsset = asset
                tradeFromButton.setTitle(fromAsset.shortCode, for: .normal)
                balanceLabel.text = "\(fromAsset.balance.decimalFormatted()) \(fromAsset.shortCode)"
                toAssetToRemove = fromAsset
                break
            }
        }
        
        guard let removableToAsset = toAssetToRemove, let removableIndex = self.stellarAccount.assets.index(of: removableToAsset) else {
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
        hud.label.text = "Placing Trade Offer..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }
    
    func setMarketPrice(orderBook: OrderbookResponse) {
        if orderBook.bids.count > 0 {
            guard let bestPrice = Float(orderBook.bids[0].price) else {
                return
            }
            
            currentMarketPrice = bestPrice
        }
    }
    
    func setCalculatedMarketPrice(tradeFromText: String) {
        guard let tradeFromValue = Float(tradeFromText) else {
            return
        }
        
        let toValue = tradeFromValue * currentMarketPrice
        tradeToTextField.text = String(toValue).decimalFormatted()
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
        if pickerView == tradeFromPickerView {
            return "\(Assets.displayTitle(shortCode: stellarAccount.assets[row].shortCode)) (\(stellarAccount.assets[row].shortCode))"
        }
        return "\(Assets.displayTitle(shortCode: toAssets[row].shortCode)) (\(toAssets[row].shortCode))"
    }
}


/*
 * Operations
 */
extension TradeViewController {
    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            if !responseAccounts.isEmpty && responseAccounts[0].assets.count > 1{
                self.stellarAccount = responseAccounts[0]
                self.setTradeSelectors(fromAsset: self.stellarAccount.assets[0], toAsset: nil)
            }
        }
    }
}


