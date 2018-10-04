//
//  P2PViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
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
        guard let accountId = KeychainHelper.accountId else {
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
        navigationItem.title = "PEER_TO_PEER".localized()

        let leftBarButtonItem = UIBarButtonItem(title: "TOKEN_ADDRESS".localized(),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self.displayAddress))

        navigationItem.leftBarButtonItem = leftBarButtonItem

        let rightBarButtonItem = UIBarButtonItem(title: "TRUSTED_PEERS".localized(),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.viewTrustedParties))

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
        guard let accountId = KeychainHelper.accountId else {
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
}
