//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol LaunchViewControllerDelegate: AnyObject {
    func requestedCreateNewWallet(_ viewController: LaunchViewController, type: StellarRecoveryMnemonic.MnemonicType)
    func requestedImportWallet(_ viewController: LaunchViewController)
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
        if KeychainHelper.accountId != nil, KeychainHelper.hasExistingInstance {
            hideButtons()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayWallet()
            }
        } else {
            showButtons()
        }
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
        let alert = UIAlertController(title: "CREATE_WALLET_TITLE".localized(),
                                      message: "CREATE_RECOVER_WALLET_MESSAGE".localized(),
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "CREATE_MNEMONIC_TWELVE".localized(),
                                      style: .default,
                                      handler: { _ in
            self.delegate?.requestedCreateNewWallet(self, type: .twelve)
        }))

        alert.addAction(UIAlertAction(title: "CREATE_MNEMONIC_TWENTYFOUR".localized(),
                                      style: .default,
                                      handler: { _ in
            self.delegate?.requestedCreateNewWallet(self, type: .twentyFour)
        }))

        alert.addAction(UIAlertAction(title: "CANCEL_ACTION".localized(), style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = createWalletButton

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func importWallet() {
        self.delegate?.requestedImportWallet(self)
    }

    func displayWallet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showButtons()
        }
    }
}
