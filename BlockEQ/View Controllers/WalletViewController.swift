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
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderLeftLabel: UILabel!
    @IBOutlet var tableViewHeaderRightLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    
    let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    var accounts: [StellarAccount] = []
    var paymentTransactions: [PaymentTransaction] = []
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        getAccountDetails()
        getPaymentTransactions()
    }
    
    func setupView() {
        let collectionViewNib = UINib(nibName: WalletCell.cellIdentifier, bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: WalletCell.cellIdentifier)
        
        let tableViewNib = UINib(nibName: TransactionHistoryCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: TransactionHistoryCell.cellIdentifier)
        
        navigationItem.titleView = logoImageView
        
        tableViewHeaderLeftLabel.textColor = Colors.darkGrayTransparent
        tableViewHeaderRightLabel.textColor = Colors.darkGrayTransparent
        pageControl.currentPageIndicatorTintColor = Colors.primaryDark
        pageControl.pageIndicatorTintColor = Colors.primaryDarkTransparent
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
    }
    
    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        accounts.removeAll()
        
        sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                print("Details: \(accountDetails.accountId, accountDetails.balances[0].balance)")
                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountDetails.accountId
                stellarAccount.balance = accountDetails.balances[0].balance
                
                self.accounts.append(stellarAccount)
                
                DispatchQueue.main.async {
                    self.pageControl.numberOfPages = self.accounts.count
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    let stellarAccount = StellarAccount()
                    stellarAccount.accountId = accountId
                    stellarAccount.balance = "0.00"
                    
                    self.accounts.append(stellarAccount)
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func getPaymentTransactions() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        paymentTransactions.removeAll()
        
        sdk.payments.getPayments(forAccount: accountId, order:Order.descending, limit: 10) { response in
            switch response {
            case .success(let paymentsResponse):
                for payment in paymentsResponse.records {
                    if let paymentResponse = payment as? PaymentOperationResponse {
                        if (paymentResponse.assetType == AssetTypeAsString.NATIVE) {
                            let paymentTransaction = PaymentTransaction()
                            paymentTransaction.amount = paymentResponse.amount
                            paymentTransaction.date = paymentResponse.createdAt
                            paymentTransaction.isReceived = paymentResponse.from != accountId ? true : false
                            
                            self.paymentTransactions.append(paymentTransaction)
                        }
                    }
                    
                    if let paymentResponse = payment as? AccountCreatedOperationResponse {
                        let paymentTransaction = PaymentTransaction()
                        paymentTransaction.amount = String(describing: paymentResponse.startingBalance)
                        paymentTransaction.date = paymentResponse.createdAt
                        paymentTransaction.isAccountCreated = true
                        
                        self.paymentTransactions.append(paymentTransaction)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeader.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryCell.cellIdentifier, for: indexPath) as! TransactionHistoryCell
        
        let paymentTransaction = paymentTransactions[indexPath.row]
        cell.amountLabel.text = paymentTransaction.formattedAmount
        cell.activityLabel.text = paymentTransaction.formattedActivity
        cell.dateLabel.text = paymentTransaction.formattedDate
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


