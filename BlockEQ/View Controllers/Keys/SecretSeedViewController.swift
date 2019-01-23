//
//  PrivateKeyViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-03.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

final class SecretSeedViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toggleVisibilityButton: AppButton!
    @IBOutlet weak var secretSeedLabel: UILabel!

    let blurEffect = UIBlurEffect(style: .light)
    let concealingView = UIVisualEffectView(effect: nil)
    var mnemonic: StellarRecoveryMnemonic?
    var passphrase: StellarMnemonicPassphrase?
    var seed: String?
    var revealed: Bool = false

    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }

    init(mnemonic: StellarRecoveryMnemonic?, passphrase: StellarMnemonicPassphrase?) {
        self.mnemonic = mnemonic
        self.passphrase = passphrase

        super.init(nibName: String(describing: SecretSeedViewController.self), bundle: nil)
    }

    init(_ seed: StellarSeed?) {
        self.seed = seed?.string
        super.init(nibName: String(describing: SecretSeedViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    func setupView() {
        containerView.addSubview(concealingView)
        containerView.constrainViewToAllEdges(concealingView)
        concealingView.backgroundColor = .clear

        navigationItem.title = "DISPLAY_SECRET_SEED_TITLE".localized()
        toggleVisibilityButton.setTitle("REVEAL_SECRET_SEED_INFORMATION".localized(), for: .normal)

        descriptionLabel.text = "DISPLAY_SECRET_SEED_DESCRIPTION".localized()
        secretSeedLabel.text = ""

        secretSeedLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center

        qrImageView.contentMode = .scaleAspectFit
        qrImageView.tintColor = Colors.primaryDark

        let navButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveToKeychain(_:)))
        navigationItem.rightBarButtonItem = navButton
    }

    func setupStyle() {
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        secretSeedLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        secretSeedLabel.textColor = Colors.darkGray
        toggleVisibilityButton.backgroundColor = Colors.primaryDark
        toggleVisibilityButton.setTitleColor(Colors.white, for: .normal)
        toggleVisibilityButton.layer.cornerRadius = 5
        toggleVisibilityButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        qrImageView.alpha = 0

        concealingView.effect = blurEffect
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        qrImageView.image = nil
        revealed = false

        displayQRCode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrImageView.image = nil
        secretSeedLabel.text = ""
    }
}

// MARK: - QR Codes
extension SecretSeedViewController {
    private func setQRCode(_ map: QRMap, text: String) {
        self.secretSeedLabel.text = text
        self.qrImageView.image = map.scaledTemplateImage(scale: 10)
        UIView.animate(withDuration: 0.5) { self.qrImageView.alpha = 1 }
    }

    private func displayQRCode() {
        if let seed = self.seed {
            self.setQRCode(QRMap(with: seed, correctionLevel: .full), text: seed)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let phrase = self.passphrase?.string

            if let mnemonic = self.mnemonic,
                let keyPair = try? Wallet.createKeyPair(mnemonic: mnemonic.string, passphrase: phrase, index: 0),
                let secretSeed = keyPair.secretSeed {
                DispatchQueue.main.async {
                    self.setQRCode(QRMap(with: secretSeed, correctionLevel: .full), text: secretSeed)
                }
            }
        }
    }
}

// MARK: - IBActions
extension SecretSeedViewController {
    @IBAction func selectedToggleButton(_ sender: Any) {
        toggleVisibility(revealText: "REVEAL_SECRET_SEED_INFORMATION".localized(),
                         concealText: "CONCEAL_SECRET_SEED_INFORMATION".localized())
    }

    @objc func saveToKeychain(_ sender: UIBarButtonItem) {
        guard let seed = self.seed else { return }

        AutoFillHelper.provider = AppleAutoFillProvider()
        AutoFillHelper.save(secret: seed) { error in
            if let error = error {
                UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                              message: error.localizedDescription,
                                              presentingViewController: self)
            } else {
                UIAlertController.simpleAlert(title: "SAVED".localized(),
                                              message: "MNEMONIC_STORED".localized(),
                                              presentingViewController: self)
            }
        }
    }
}

// MARK: - Blurrable
extension SecretSeedViewController: Blurrable {
    var blurContainerView: UIView? { return containerView }
    var toggleButton: UIButton? { return toggleVisibilityButton }
}
