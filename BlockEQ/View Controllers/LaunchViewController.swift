//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    func requestedCreateNewWallet(_ vc: LaunchViewController, type: MnemonicType)
    func requestedImportWallet(_ vc: LaunchViewController)
}

class LaunchViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var createWalletButton: UIButton!
    @IBOutlet var importWalletButton: UIButton!
    @IBOutlet var logoImageView: UIImageView!

    weak var delegate: LaunchViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: String(describing: LaunchViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        checkForExistingAccount()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    func setupView() {
        navigationController?.isNavigationBarHidden = true

        logoImageView.image = UIImage(named: "logo")

        createWalletButton.backgroundColor = Colors.primaryDark
        createWalletButton.setTitleColor(Colors.white, for: .normal)
        importWalletButton.backgroundColor = Colors.secondaryDark
        importWalletButton.setTitleColor(Colors.white, for: .normal)
        view.backgroundColor = Colors.backgroundDark
    }

    func checkForExistingAccount() {
        if let _ = KeychainHelper.getAccountId(), KeychainHelper.isExistingInstance() {
            hideButtons()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayWallet()
            }
        } else {
            showButtons()
        }
    }

    func createAccount(mnemonic: String) {
        hideButtons()
        displayWallet()
    }

    func hideButtons() {
        activityIndicator.startAnimating()
        createWalletButton.isHidden = true
        importWalletButton.isHidden = true
    }

    func showButtons() {
        activityIndicator.stopAnimating()
        createWalletButton.isHidden = false
        importWalletButton.isHidden = false
    }

    @IBAction func createNewWallet() {
        let alert = UIAlertController(title: "Create Wallet", message: "Please select from the following 2 options:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Use a 12 word recovery phrase", style: .default , handler:{ (UIAlertAction)in
            self.delegate?.requestedCreateNewWallet(self, type: .twelve)
        }))
        
        alert.addAction(UIAlertAction(title: "Use a 24 word recovery phrase", style: .default , handler:{ (UIAlertAction)in
            self.delegate?.requestedCreateNewWallet(self, type: .twentyFour)
        }))
        
        alert.addAction(UIAlertAction(title: "Cance", style: .cancel, handler:{ (UIAlertAction)in
        }))
        
        alert.popoverPresentationController?.sourceView = createWalletButton
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    @IBAction func importWallet() {
        delegate?.requestedImportWallet(self)
    }

    func displayWallet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showButtons()
        }
    }
}
