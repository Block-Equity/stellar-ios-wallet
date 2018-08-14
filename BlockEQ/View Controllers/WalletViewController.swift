//
//  WalletViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

protocol WalletViewControllerDelegate: AnyObject {
    func selectedWalletSwitch(_ vc: WalletViewController, account: StellarAccount)
    func selectedSend(_ vc: WalletViewController, account: StellarAccount, index: Int)
    func selectedReceive()
    func selectBalance(account: StellarAccount, index: Int)
}

class WalletViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var availableBalanceLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var emptyViewTitleLabel: UILabel!
    @IBOutlet var headerBackgroundView: UIView!
    @IBOutlet var availableBalanceView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderLeftLabel: UILabel!
    @IBOutlet var tableViewHeaderRightLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    weak var delegate: WalletViewControllerDelegate?
    var navigationContainer: AppNavigationController?
    
    var accounts: [StellarAccount] = []
    var effects: [StellarEffect] = []
    var isLoadingTransactionsOnViewLoad = true
    var isShowingSeed = true
    var timer: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var currentAssetIndex = 0
    var paymentStream: Any!
    var isNativeAsset: Bool = false
    
    @IBAction func sendFunds() {
        let currentStellarAccount = accounts[0]
        delegate?.selectedSend(self, account: currentStellarAccount, index: currentAssetIndex)
    }
    
    @IBAction func selectBalance() {
        let currentStellarAccount = accounts[0]
        delegate?.selectBalance(account: currentStellarAccount, index: currentAssetIndex)
    }
    
    @IBAction func displayWalletSwitcher() {
        let currentStellarAccount = accounts[0]
        delegate?.selectedWalletSwitch(self, account: currentStellarAccount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        checkForPaymentReceived()
        startPollingForAccountFunding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarStyle = .default
        
        getAccountDetails()
    }
    
    deinit {
        stopTimer()
    }
    
    func setupView() {
        let tableViewNib = UINib(nibName: TransactionHistoryCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: TransactionHistoryCell.cellIdentifier)
        
        /*
        logoImageView.tintColor = Colors.primaryDark
        navigationItem.titleView = logoImageView*/
        
        navigationItem.title = "Wallet"

        let leftBarButtonItem = UIBarButtonItem(title: "Receive", style: .plain, target: self, action: #selector(self.receiveFunds))
        navigationItem.leftBarButtonItem = leftBarButtonItem

        let rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(self.sendFunds))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        availableBalanceView.backgroundColor = Colors.darkGray
        headerBackgroundView.backgroundColor = Colors.primaryDark
        coinLabel.textColor = Colors.white
        balanceLabel.textColor = Colors.white
        emptyViewTitleLabel.textColor = Colors.darkGray
        tableViewHeaderLeftLabel.textColor = Colors.darkGrayTransparent
        tableViewHeaderRightLabel.textColor = Colors.darkGrayTransparent
        tableView.backgroundColor = Colors.lightBackground
    }
    
    func startPollingForAccountFunding() {
        timer.schedule(deadline: .now(), repeating: .seconds(30))
        timer.setEventHandler {
            self.getAccountDetails()
        }
        
        timer.resume()
    }
    
    func stopTimer() {
        timer.cancel()
    }
    
    @objc func receiveFunds() {
        delegate?.selectedReceive()
    }
}

extension WalletViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletCell.cellIdentifier, for: indexPath) as! WalletCell
        let stellarAccount = accounts[indexPath.row]
        
        if isLoadingTransactionsOnViewLoad {
            cell.amountLabel.text = ""
        } else {
            cell.amountLabel.text = stellarAccount.assets[currentAssetIndex].formattedBalance
        }
        
        cell.currencyLabel.text = stellarAccount.assets[currentAssetIndex].shortCode
        
        return cell
    }
}

extension WalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return effects.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            if isNativeAsset {
                return availableBalanceView
            }
            return nil
        case 1:
            return tableViewHeader
        default:
            if isLoadingTransactionsOnViewLoad && !activityIndicator.isAnimating {
                return emptyView
            }
           return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if isNativeAsset {
                return availableBalanceView.frame.size.height
            }
            return 0
        case 1:
            return tableViewHeader.frame.size.height
        default:
            if isLoadingTransactionsOnViewLoad && !activityIndicator.isAnimating {
                return emptyView.frame.size.height
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryCell.cellIdentifier, for: indexPath) as! TransactionHistoryCell
        let effect = effects[indexPath.row]
        
        let stellarAsset = self.accounts[0].assets[currentAssetIndex]
        cell.amountLabel.text = effect.formattedTransactionAmount(asset: stellarAsset)
        cell.dateLabel.text = effect.formattedDate
        cell.activityLabel.text = effect.formattedDescription(asset: stellarAsset)
        cell.transactionDisplayView.backgroundColor = effect.color(asset: stellarAsset)
        
        return cell
    }

    func selectAsset(at index: Int) {
        currentAssetIndex = index
        isNativeAsset = false
        balanceLabel.text = ""
        coinLabel.text = ""
        isLoadingTransactionsOnViewLoad = true
        activityIndicator.startAnimating()
        effects.removeAll()
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getAccountDetails()
        }
    }
}

extension WalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryCell.rowHeight
    }
}

/*
 * Operations
 */
extension WalletViewController {
    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.accounts = responseAccounts
            
            if responseAccounts.isEmpty {
                self.accounts.removeAll()
                
                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountId
                
                let stellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "0.0000")

                stellarAccount.assets.removeAll()
                stellarAccount.assets.append(stellarAsset)
                
                self.accounts.append(stellarAccount)
            }
            let asset = self.accounts[0].assets[self.currentAssetIndex]
            
            if asset.shortCode == "XLM" {
                self.isNativeAsset = true
            } else {
                self.isNativeAsset = false
            }
            
            if Assets.displayTitle(shortCode: asset.shortCode) == asset.shortCode {
                self.coinLabel.text = "\(Assets.displayTitle(shortCode: asset.shortCode))"
            } else {
                self.coinLabel.text = "\(Assets.displayTitle(shortCode: asset.shortCode)) (\(asset.shortCode))"
            }
            
            self.availableBalanceLabel.text = "Available:  \(self.accounts[0].formattedAvailableBalance) XLM"
            self.balanceLabel.text = asset.balance.decimalFormatted()
            self.getEffects()
        }
    }
    
    func getEffects() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }

        guard self.accounts.count > 0 else {
            return
        }

        let account = self.accounts[0]

        guard account.assets.count > 0 else {
            return
        }

        let stellarAsset = self.accounts[0].assets[currentAssetIndex]
        
        PaymentTransactionOperation.getTransactions(accountId: accountId, stellarAsset: stellarAsset) { transactions in
            self.effects = transactions
            
            if self.effects.count > 0 {
                self.isLoadingTransactionsOnViewLoad = false
                self.stopTimer()
            }
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func checkForPaymentReceived() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        paymentStream = Stellar.sdk.payments.stream(for: .paymentsForAccount(account: accountId, cursor: "now")).onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(_, let operationResponse):
                if operationResponse is PaymentOperationResponse {
                    DispatchQueue.main.async {
                         self.getAccountDetails()
                    }
                }
            case .error(let error):
                if let horizonRequestError = error as? HorizonRequestError {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Receive payment", horizonRequestError:horizonRequestError)
                }
            }
        }
    }
}
