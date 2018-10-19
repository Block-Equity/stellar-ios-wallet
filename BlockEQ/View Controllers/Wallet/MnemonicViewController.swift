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
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController, mnemonic: StellarRecoveryMnemonic)
}

class MnemonicViewController: UIViewController {
    @IBOutlet var holderView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mnemonicHolderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var confirmationButton: AppButton!

    weak var delegate: MnemonicViewControllerDelegate?

    var mnemonic: StellarRecoveryMnemonic?
    var hideConfirmation: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mnemonic = StellarRecoveryMnemonic(Wallet.generate24WordMnemonic())
    }

    init(mnemonic: StellarRecoveryMnemonic?, shouldSetPin: Bool, hideConfirmation: Bool = false) {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)
        self.hideConfirmation = hideConfirmation
        self.mnemonic = mnemonic
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        generateMnemonicViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = mnemonic != nil ? "MNEMONIC_REMINDER_MESSAGE".localized() : "NO_MNEMONIC_SET".localized()
        self.confirmationButton.isHidden = self.hideConfirmation
    }

    func setupView() {
        navigationItem.title = "SECRET_PHRASE".localized()
        title = "SECRET_PHRASE".localized()

        holderView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGray

        let navButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveToKeychain(_:)))
        navigationItem.rightBarButtonItem = navButton
    }

    @IBAction func confirmedWrittenDown(_ sender: Any) {
        guard let mnemonic = self.mnemonic else { return }
        delegate?.confirmedWrittenMnemonic(self, mnemonic: mnemonic)
    }

    @objc func saveToKeychain(_ sender: UIBarButtonItem) {
        guard let mnemonic = self.mnemonic?.string else { return }
        AutoFillHelper.provider = AppleAutoFillProvider()
        AutoFillHelper.save(mnemonic: mnemonic) { error in
            if let error = error {
                UIAlertController.simpleAlert(title: "ERROR_TITLE",
                                              message: error.localizedDescription,
                                              presentingViewController: self)
            } else {
                UIAlertController.simpleAlert(title: "SAVED".localized(),
                                              message: "MNEMONIC_STORED".localized(),
                                              presentingViewController: self)
            }
        }
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
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
