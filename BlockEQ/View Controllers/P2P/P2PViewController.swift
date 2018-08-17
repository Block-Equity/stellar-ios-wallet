//
//  P2PViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-01.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol P2PViewControllerDelegate: AnyObject {
    func selectedAddPeer()
    func selectedAddTransaction()
    func selectedCreateToken()
    func selectedDisplayAddress(accountId: String)
    func selectedTrustedParties()
}

class P2PViewController: UIViewController {
    
    @IBOutlet var headerBackgroundView: UIView!
    @IBOutlet var headerOverlayView: UIView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var tokenLabel: UILabel!
    
    weak var delegate: P2PViewControllerDelegate?
    
    @IBAction func addPeer() {
        delegate?.selectedAddPeer()
    }
    
    @IBAction func addTransaction() {
        delegate?.selectedAddTransaction()
    }
    
    @IBAction func createToken() {
        delegate?.selectedCreateToken()
    }
    
    @IBAction func displayAddress() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        delegate?.selectedDisplayAddress(accountId: accountId)
    }
    
    @IBAction func viewTrustedParties() {
        delegate?.selectedTrustedParties()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPersonToken()
    }
    
    func setupView() {
        navigationItem.title = "Peer to Peer"
        
        let leftBarButtonItem = UIBarButtonItem(title: "Token Address", style: .plain, target: self, action: #selector(self.displayAddress))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "Trusted Peers", style: .plain, target: self, action: #selector(self.viewTrustedParties))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        headerBackgroundView.backgroundColor = Colors.primaryDark
        headerOverlayView.backgroundColor = Colors.primaryDark
        balanceLabel.textColor = Colors.white
        tokenLabel.textColor = Colors.white
    }
}

/*
 * Operations
 */
extension P2PViewController {
    func getPersonToken() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        AccountOperation.getPersonalToken(address: accountId) { personalToken in
            if let token = personalToken, !token.isEmpty {
                self.headerOverlayView.isHidden = true
                self.tokenLabel.text = token
            } else {
                self.headerOverlayView.isHidden = false
            }
        }
    }
    /*
    func createTrustLine(issuerAccountId: String, assetCode: String) {
        showHud()
        
        PaymentTransactionOperation.changeTrust(issuerAccountId: issuerAccountId, assetCode: assetCode, limit: 10000000000) { completed
            in
            
            if completed {
                self.getAccountDetails()
            } else {
                self.hideHud()
                
                let alert = UIAlertController(title: "Activation Error", message: "Sorry your asset could not be added at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getAccountDetails() {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }
        
        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.hideHud()
            
            if responseAccounts.count > 0 {
                self.delegate?.didAddAsset(stellarAccount: responseAccounts[0])
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }*/
}

