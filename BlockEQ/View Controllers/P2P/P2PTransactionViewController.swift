//
//  P2PTransactionViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

enum P2PTradeType: Int {
    case buy
    case sell

    static var all: [P2PTradeType] {
        return [.buy, .sell]
    }
}

class P2PTransactionViewController: UIViewController {

    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var balanceLabel: UILabel!
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

    let tradeFromPickerView = UIPickerView()
    var stellarAccount = StellarAccount()
    var peers: [StellarAsset] = []
    var currentPeer: StellarAsset!
    var currentTradeType: P2PTradeType = .buy

    @IBAction func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func tradeFromSelected() {
        tradeFromSelectorTextField.becomeFirstResponder()
    }

    @IBAction func tradeTypeSwitched(sender: UISegmentedControl) {
        currentTradeType = P2PTradeType.all[sender.selectedSegmentIndex]
        setTradeViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ADD_TRANSACTION".localized()

        tradeFromView.layer.borderWidth = 0.5
        tradeToView.layer.borderWidth = 0.5

        arrowImageView.tintColor = Colors.lightGray
        balanceLabel.textColor = Colors.darkGray
        marketLabelHolderView.backgroundColor = Colors.lightBackground
        segmentControl.tintColor = Colors.lightGray
        tableview.backgroundColor = Colors.lightBackground
        tradeFromTextField.textColor = Colors.darkGray
        tradeToTextField.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: .selected)

        tradeToButton.setTitle("XLM", for: .normal)

        tradeFromPickerView.dataSource = self
        tradeFromPickerView.delegate = self
        tradeFromSelectorTextField.inputView = tradeFromPickerView

        setTradeViews()
    }

    func setTradeViews() {
        if currentTradeType == .buy {
            tradeFromButton.backgroundColor = Colors.green
            tradeFromView.layer.borderColor = Colors.green.cgColor

            tradeToButton.backgroundColor = Colors.red
            tradeToView.layer.borderColor = Colors.red.cgColor
        } else {
            tradeFromButton.backgroundColor = Colors.red
            tradeFromView.layer.borderColor = Colors.red.cgColor

            tradeToButton.backgroundColor = Colors.green
            tradeToView.layer.borderColor = Colors.green.cgColor
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getAccountDetails()
    }
}

extension P2PTransactionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return peers.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentPeer = peers[row]
        tradeFromButton.setTitle("\(Assets.displayTitle(shortCode: peers[row].shortCode))", for: .normal)
    }
}

extension P2PTransactionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return "\(Assets.displayTitle(shortCode: peers[row].shortCode))"
    }
}

/*
 * Operations
 */
extension P2PTransactionViewController {
    func getAccountDetails() {
        guard let accountId = KeychainHelper.accountId else {
            return
        }

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            if !responseAccounts.isEmpty && responseAccounts[0].assets.count > 1 {
                self.stellarAccount = responseAccounts[0]

                self.peers.removeAll()

                for asset in self.stellarAccount.assets {
                    if asset.shortCode.contains("XLM") && asset.assetType == AssetTypeAsString.CREDIT_ALPHANUM12 {
                        self.peers.append(asset)
                    }
                }
                self.tradeFromPickerView.reloadAllComponents()

                if self.currentPeer == nil {
                    let code = self.peers[0].shortCode
                    self.currentPeer = self.peers[0]
                    self.tradeFromPickerView.selectRow(0, inComponent: 0, animated: false)
                    self.tradeFromButton.setTitle("\(Assets.displayTitle(shortCode: code))", for: .normal)
                }
            }
        }
    }
}
