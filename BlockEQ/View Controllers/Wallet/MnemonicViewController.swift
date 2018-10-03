//
//  MnemonicViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

protocol MnemonicViewControllerDelegate: AnyObject {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController, mnemonic: String)
}

class MnemonicViewController: UIViewController {
    @IBOutlet var holderView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mnemonicHolderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var confirmationButton: AppButton!

    weak var delegate: MnemonicViewControllerDelegate?

    var mnemonic: String!
    var hideConfirmation: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mnemonic = Wallet.generate24WordMnemonic()
    }

    init(mnemonic: String?, shouldSetPin: Bool, hideConfirmation: Bool = false, mnemonicType: MnemonicType) {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)

        if mnemonicType == .twelve {
            self.mnemonic = mnemonic ?? Wallet.generate12WordMnemonic()
        } else {
            self.mnemonic = mnemonic ?? Wallet.generate24WordMnemonic()
        }

        self.hideConfirmation = hideConfirmation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        generateMnemonicViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.confirmationButton.isHidden = self.hideConfirmation
    }

    func setupView() {
        navigationItem.title = "SECRET_PHRASE".localized()
        title = "SECRET_PHRASE".localized()

        holderView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGray
    }

    @IBAction func confirmedWrittenDown(_ sender: Any) {
        delegate?.confirmedWrittenMnemonic(self, mnemonic: mnemonic)
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func generateMnemonicViews() {
        activityIndicator.stopAnimating()

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
