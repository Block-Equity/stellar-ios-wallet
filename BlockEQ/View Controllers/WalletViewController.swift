//
//  WalletViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class WalletViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyViewTitleLabel: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderLeftLabel: UILabel!
    @IBOutlet var tableViewHeaderRightLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!

    var navigationContainer: AppNavigationController?
    let walletSwitchingViewController = WalletSwitchingViewController()
    let navigationMenuViewController = NavigationMenuViewController()
    
    var accounts: [StellarAccount] = []
    var paymentTransactions: [PaymentTransaction] = []
    var isLoadingTransactionsOnViewLoad = true
    var isShowingSeed = true
    var timer: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var currentAssetIndex = 0
    var paymentStream: Any!
    
    @IBAction func receiveFunds() {
        let currentStellarAccount = accounts[pageControl.currentPage]
        let receiveViewController = ReceiveViewController(address: currentStellarAccount.accountId)
        let navigationController = AppNavigationController(rootViewController: receiveViewController)

        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func sendFunds() {
        let currentStellarAccount = accounts[pageControl.currentPage]
        let sendViewController = SendViewController(stellarAccount: currentStellarAccount, currentAssetIndex: currentAssetIndex)
        let navigationController = AppNavigationController(rootViewController: sendViewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationContainer = AppNavigationController(rootViewController: walletSwitchingViewController)
        walletSwitchingViewController.delegate = self
        navigationMenuViewController.delegate = self
    }
    
    init() {
        super.init(nibName: String(describing: WalletViewController.self), bundle: nil)
        navigationContainer = AppNavigationController(rootViewController: walletSwitchingViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        walletSwitchingViewController.delegate = self
        navigationMenuViewController.delegate = self

        setupView()
        checkForPaymentReceived()
        startPollingForAccountFunding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        getAccountDetails()
    }
    
    deinit {
        stopTimer()
    }
    
    func setupView() {
        let collectionViewNib = UINib(nibName: WalletCell.cellIdentifier, bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: WalletCell.cellIdentifier)
        
        let tableViewNib = UINib(nibName: TransactionHistoryCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: TransactionHistoryCell.cellIdentifier)
        
        navigationItem.titleView = logoImageView

        let imageSettings = UIImage(named:"wallet")
        let leftBarButtonItem = UIBarButtonItem(image: imageSettings, style: .plain, target: self, action: #selector(self.displayMenu))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        emptyViewTitleLabel.textColor = Colors.darkGray
        tableViewHeaderLeftLabel.textColor = Colors.darkGrayTransparent
        tableViewHeaderRightLabel.textColor = Colors.darkGrayTransparent
        pageControl.currentPageIndicatorTintColor = Colors.primaryDark
        pageControl.pageIndicatorTintColor = Colors.primaryDarkTransparent
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
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
    
    @objc func displayMenu() {
        guard let viewController = self.navigationContainer else {
            return
        }

        present(viewController, animated: true, completion: nil)
    }
    
    @objc func displayNavigation() {
        print("DO SOMETHING")
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

extension WalletViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: collectionView.frame.size.height)
    }
}

extension WalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return paymentTransactions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
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
        
        let paymentTransaction = paymentTransactions[indexPath.row]
        cell.amountLabel.text = paymentTransaction.formattedAmount
        cell.dateLabel.text = paymentTransaction.formattedDate
        cell.setTitle(isAccountCreated: paymentTransaction.isAccountCreated, isPaymentReceived: paymentTransaction.isReceived)
        
        return cell
    }
}

extension WalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryCell.rowHeight
    }
}

extension WalletViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        }
    }
}

extension WalletViewController: PinViewControllerDelegate {
    func pinConfirmationSucceeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isShowingSeed {
                let mnemonicViewController = MnemonicViewController(mnemonic: KeychainHelper.getMnemonic(), shouldSetPin: false)
                let navigationController = AppNavigationController(rootViewController: mnemonicViewController)
                
                self.present(navigationController, animated: true, completion: nil)
            } else {
                self.paymentStream = nil
                KeychainHelper.clearAll()
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension WalletViewController: WalletSwitchingViewControllerDelegate {
    func didSelectSetInflation() {
        let inflationViewController = InflationViewController()
        self.navigationContainer?.pushViewController(inflationViewController, animated: true)
    }

    func didSelectAsset(index: Int) {
        currentAssetIndex = index
        
        isLoadingTransactionsOnViewLoad = true
        activityIndicator.startAnimating()
        paymentTransactions.removeAll()
        collectionView.reloadData()
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getAccountDetails()
        }
    }
    
    func reloadAssets() {
        getAccountDetails()
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
                
                let stellarAsset = StellarAsset()
                stellarAsset.balance = "0.00"
                stellarAsset.assetType = AssetTypeAsString.NATIVE
                
                stellarAccount.assets.removeAll()
                stellarAccount.assets.append(stellarAsset)
                
                self.accounts.append(stellarAccount)
            }
            
            self.walletSwitchingViewController.updateMenu(stellarAccount: self.accounts[self.pageControl.currentPage])
            self.getPaymentTransactions()
        }
    }
    
    func getPaymentTransactions() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        let stellarAsset = self.accounts[pageControl.currentPage].assets[currentAssetIndex]
        
        PaymentTransactionOperation.getTransactions(accountId: accountId, stellarAsset: stellarAsset) { transactions in
            self.paymentTransactions = transactions
            
            if self.paymentTransactions.count > 0 {
                self.isLoadingTransactionsOnViewLoad = false
                self.stopTimer()
            }
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
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

extension WalletViewController: SettingsDelegate {
    func selected(setting: SettingNode) {
        switch setting {
        case .node(_, let identifier, _) where identifier == "wallet-view-seed": displayPin(isShowingSeed: true)
        case .node(_, let identifier, _) where identifier == "wallet-clear": clearWallet()
        default: print("Selected: \(String(describing: setting.name))")
        }
    }

    func clearWallet() {
        let alertController = UIAlertController(title: "Are you sure you want to clear this wallet?", message: nil, preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "Clear", style: .destructive, handler: { (action) -> Void in
            self.displayPin(isShowingSeed: false)
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        navigationController?.present(alertController, animated: true, completion: nil)
    }

    func displayPin(isShowingSeed: Bool) {
        self.isShowingSeed = isShowingSeed

        let pinViewController = PinViewController(pin: KeychainHelper.getPin(), mnemonic: nil, isSendingPayment: true, isEnteringApp: false)
        pinViewController.delegate = self
        let navigationController = AppNavigationController(rootViewController: pinViewController)

        present(navigationController, animated: true, completion: nil)
    }
}

extension WalletViewController: NavigationMenuViewControllerDelegate {
    func selected(_ option: MenuItem) {
        switch option {
        case .wallet: print("TODO: Display main wallet view controller") // Switch main view controller to wallet
        case .trading: print("TODO: Display trading wallet view controller") // Switch main view controller to trading
        case .settings:
            let settingsController = SettingsViewController(options: EQSettings().options)
            settingsController.delegate = self

            let settingsContainer = SettingsContainerViewController(rootViewController: settingsController)
            navigationController?.present(settingsContainer, animated: true, completion: nil)
        }
    }
}
