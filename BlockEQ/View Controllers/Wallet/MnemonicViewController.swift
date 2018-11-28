//
//  MnemonicViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

protocol MnemonicViewControllerDelegate: AnyObject {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController,
                                  mnemonic: StellarRecoveryMnemonic,
                                  passphrase: StellarMnemonicPassphrase?)
}

class MnemonicViewController: UIViewController {
    @IBOutlet var holderView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mnemonicHolderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var advancedSecurityButton: UIButton!
    @IBOutlet weak var confirmationButton: AppButton!

    weak var delegate: MnemonicViewControllerDelegate?

    var mnemonic: StellarRecoveryMnemonic?
    var hideConfirmation: Bool = false
    var hideAdvancedSecurity: Bool = true
    var mnemonicPassphrase: StellarMnemonicPassphrase?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mnemonic = StellarRecoveryMnemonic(Wallet.generate24WordMnemonic())
    }

    init(mnemonic: StellarRecoveryMnemonic?, hideConfirmation: Bool = false, advancedSecurity: Bool = false) {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)
        self.hideConfirmation = hideConfirmation
        self.hideAdvancedSecurity = !advancedSecurity
        self.mnemonic = mnemonic
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        generateMnemonicViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = mnemonic != nil ? "MNEMONIC_REMINDER_MESSAGE".localized() : "NO_MNEMONIC_SET".localized()
        self.confirmationButton.isHidden = self.hideConfirmation
        mnemonicPassphrase = nil

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mnemonicPassphrase = nil
    }

    func setupView() {
        navigationItem.title = "SECRET_PHRASE".localized()
        title = "SECRET_PHRASE".localized()

        confirmationButton.setTitle("CONFIRMED_SECRET_TITLE".localized(), for: .normal)

        holderView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGray

        let navButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveToKeychain(_:)))
        navigationItem.rightBarButtonItem = navButton

        advancedSecurityButton.isHidden = hideAdvancedSecurity

        styleAdvancedSecurity()
    }

    func generateMnemonicViews() {
        activityIndicator.stopAnimating()

        guard let mnemonic = self.mnemonic?.string else { return }

        let words = mnemonic.components(separatedBy: " ")
        var originX: CGFloat = 0.0
        var originY: CGFloat = 0.0

        for (index, word) in words.enumerated() {
            let pillView = PillView(index: String(index + 1), title: word, origin: .zero)

            if index == 0 {
                mnemonicHolderView.addSubview(pillView)
                originX += pillView.frame.size.width
            } else {
                let delta = mnemonicHolderView.frame.size.width - pillView.horizontalSpacing
                if originX + pillView.frame.size.width > delta {
                    originY += pillView.verticalSpacing
                    originX = 0.0
                } else {
                    originX += pillView.horizontalSpacing
                }

                pillView.frame.origin = CGPoint(x: originX, y: originY)

                mnemonicHolderView.addSubview(pillView)

                originX += pillView.frame.size.width
            }
        }
    }
}

// MARK: - IBActions / Actions
extension MnemonicViewController {
    @IBAction func confirmedWrittenDown(_ sender: Any) {
        guard let mnemonic = self.mnemonic else { return }
        delegate?.confirmedWrittenMnemonic(self, mnemonic: mnemonic, passphrase: mnemonicPassphrase)
    }

    @IBAction func selectedAdvancedSecurity(_ sender: Any) {
        self.mnemonicPassphrase = nil
        self.passphrasePrompt(confirm: false, completion: self.setPassphrase)
    }

    @objc func saveToKeychain(_ sender: UIBarButtonItem) {
        guard let mnemonic = self.mnemonic?.string else { return }

        let keychainProvider = AppleAutoFillProvider()
        AutoFillHelper.provider = keychainProvider

        AutoFillHelper.save(mnemonic: mnemonic) { error in
            if let error = error {
                UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                              message: error.localizedDescription,
                                              presentingViewController: self)
            } else {
//                This has been removed to not scare users since the error case is never triggered even if the user
//                selects "don't allow" in the OS prompt.
//
//                A radar bug has been filed with Apple for this.

//
//                UIAlertController.simpleAlert(title: "SAVED".localized(),
//                                              message: "MNEMONIC_STORED".localized(),
//                                              presentingViewController: self)
            }
        }
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}
