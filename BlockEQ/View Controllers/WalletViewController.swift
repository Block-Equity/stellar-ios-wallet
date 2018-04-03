//
//  WalletViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

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
    
    var accounts: [StellarAccount] = []
    var paymentTransactions: [PaymentTransaction] = []
    var isLoadingTransactionsOnViewLoad = true
    var isShowingSeed = true
    var timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    @IBAction func receiveFunds() {
        let currentStellarAccount = accounts[pageControl.currentPage]
        let receiveViewController = ReceiveViewController(address: currentStellarAccount.accountId)
        let navigationController = AppNavigationController(rootViewController: receiveViewController)

        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func sendFunds() {
        let currentStellarAccount = accounts[pageControl.currentPage]
        let sendViewController = SendViewController(stellarAccount: currentStellarAccount)
        let navigationController = AppNavigationController(rootViewController: sendViewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: WalletViewController.self), bundle: nil)
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
        
        getAccountDetails()
        getPaymentTransactions()
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
        
        let image = UIImage(named:"settings")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.displayOptions))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
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
            self.getPaymentTransactions()
        }
        
        timer.resume()
    }
    
    func stopTimer() {
        timer.cancel()
    }
    
    @objc func displayOptions() {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        let mnemonicButton = UIAlertAction(title: "View Seed Phrase", style: .default, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
            
            self.displayPin(isShowingSeed: true)
        })
        
        let clearWalletButton = UIAlertAction(title: "Clear Wallet", style: .default, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
            
            self.clearWallet()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(mnemonicButton)
        alertController.addAction(clearWalletButton)
        alertController.addAction(cancelButton)
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clearWallet() {
        let alertController = UIAlertController(title: "Are you sure you want to clear this wallet?", message: nil, preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
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

extension WalletViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletCell.cellIdentifier, for: indexPath) as! WalletCell
        let stellarAccount = accounts[indexPath.row]
        
        cell.amountLabel.text = stellarAccount.formattedBalance
        
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
            if isLoadingTransactionsOnViewLoad {
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
            if isLoadingTransactionsOnViewLoad {
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
                KeychainHelper.clearAll()
                
                self.navigationController?.popViewController(animated: true)
            }
        }
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
                stellarAccount.balance = "0.00"
                
                self.accounts.append(stellarAccount)
            }
            
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func getPaymentTransactions() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        PaymentTransactionOperation.getTransactions(accountId: accountId) { transactions in
            self.paymentTransactions = transactions
            
            if self.paymentTransactions.count > 0 {
                self.isLoadingTransactionsOnViewLoad = false
                self.stopTimer()
            }
            self.tableView.reloadData()
        }
    }
    
    func checkForPaymentReceived() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        PaymentTransactionOperation.receivedPayment(accountId: accountId) { received in
            if (received) {
                self.getAccountDetails()
                self.getPaymentTransactions()
            }
        }
    }
}


