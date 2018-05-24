//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    func requestedCreateNewWallet(_ vc: LaunchViewController)
    func requestedImportWallet(_ vc: LaunchViewController)
}

class LaunchViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var createWalletButton: UIButton!
    @IBOutlet var importWalletButton: UIButton!
    @IBOutlet var logoImageView: UIImageView!

    weak var delegate: LaunchViewControllerDelegate?

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
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setupView() {
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
            showButtons()
        }
    }
    
    func createStellarAccount(mnemonic: String) {
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
        delegate?.requestedCreateNewWallet(self)
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
