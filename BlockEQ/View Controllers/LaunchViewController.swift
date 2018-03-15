//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var createWalletButton: UIButton!
    @IBOutlet var importWalletButton: UIButton!
    @IBOutlet var logoImageView: UIImageView!
    
    let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    
    @IBAction func createNewWallet() {
        let mnemonicViewController = MnemonicViewController()
        let navigationController = AppNavigationController(rootViewController: mnemonicViewController)
        navigationController.accountCreationDelegate = self

        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func importWallet() {
        let verificationViewController = VerificationViewController(type: .recovery, mnemonic: "")
        let navigationController = AppNavigationController(rootViewController: verificationViewController)
        navigationController.accountCreationDelegate = self
        
        present(navigationController, animated: true, completion: nil)
    }

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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        showButtons()
    }
    
    func setupView() {
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationController?.isNavigationBarHidden = true
        
        logoImageView.image = UIImage(named: "logo")
        
        createWalletButton.backgroundColor = Colors.tertiaryDark
        createWalletButton.setTitleColor(Colors.white, for: .normal)
        importWalletButton.backgroundColor = Colors.whiteTransparent
        importWalletButton.setTitleColor(Colors.white, for: .normal)
        view.gradientLayer.colors = [Colors.secondaryDark.cgColor, Colors.primaryDark.cgColor]
        view.gradientLayer.gradient = GradientPoint.topBottom.draw()
    }
    
    func checkForExistingAccount() {
        if let _ = KeychainHelper.getAccountId(), KeychainHelper.isExistingInstance() {
            hideButtons()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayWallet()
            }
        } else {
            KeychainHelper.clearAll()
        }
    }
    
    func createStellarAccount(mnemonic: String) {
        hideButtons()
        
        let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0)
        
        let publicKeyData = NSData(bytes: keyPair.publicKey.bytes, length: keyPair.publicKey.bytes.count) as Data
        let privateBytes = keyPair.privateKey?.bytes ?? [UInt8]()
        let privateKeyData = NSData(bytes: privateBytes, length: privateBytes.count) as Data
        
        KeychainHelper.save(accountId: keyPair.accountId)
        KeychainHelper.save(publicKey: publicKeyData)
        KeychainHelper.save(privateKey: privateKeyData)
        
        print(keyPair.secretSeed)
        
        /// Use friendbot to fund test account
        /*
        sdk.accounts.createTestAccount(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                print("Details: \(data)")
                DispatchQueue.main.async {
                    self.displayWallet()
                }
                
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.displayWallet()
                }
            }
        }*/
        
        self.displayWallet()
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
    
    func displayWallet() {
        let walletViewController = WalletViewController()
        
        navigationController?.pushViewController(walletViewController, animated: true)
    }
}

extension LaunchViewController: AccountCreationDelegate {
    func createAccount(mnemonic: String) {
        createStellarAccount(mnemonic: mnemonic)
    }
}
