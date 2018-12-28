//
//  MnemonicViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol MnemonicViewControllerDelegate: AnyObject {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController,
                                  mnemonic: StellarRecoveryMnemonic,
                                  passphrase: StellarMnemonicPassphrase?)
}

class MnemonicViewController: UIViewController {
    enum MnemonicMode {
        case view
        case confirm

        var hideConfirmation: Bool {
            switch self {
            case .confirm: return false
            case .view: return false
            }
        }

        var hideAdvancedSecurity: Bool {
            switch self {
            case .confirm: return false
            case .view: return true
            }
        }
    }

    @IBOutlet var holderView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var advancedSecurityButton: UIButton!
    @IBOutlet weak var confirmationButton: AppButton!

    weak var delegate: MnemonicViewControllerDelegate?

    let blurEffect = UIBlurEffect(style: .light)
    let concealingView = UIVisualEffectView(effect: nil)
    var mnemonic: StellarRecoveryMnemonic?
    var mode: MnemonicMode = .confirm
    var revealed: Bool = false

    var temporaryPassphrase: StellarMnemonicPassphrase?
    var mnemonicPassphrase: StellarMnemonicPassphrase? {
        didSet {
            collectionView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mnemonic = StellarRecoveryMnemonic(Wallet.generate24WordMnemonic())
    }

    init(mnemonic: StellarRecoveryMnemonic?, passphrase: StellarMnemonicPassphrase? = nil, mode: MnemonicMode = .view) {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)
        self.mnemonic = mnemonic
        self.mnemonicPassphrase = passphrase
        self.mode = mode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = mnemonic != nil ? "MNEMONIC_REMINDER_MESSAGE".localized() : "NO_MNEMONIC_SET".localized()
        self.confirmationButton.isHidden = mode.hideConfirmation

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        mnemonicPassphrase = nil
    }

    func setupView() {
        navigationItem.title = "SECRET_PHRASE".localized()
        title = "SECRET_PHRASE".localized()

        if mode == .confirm {
            confirmationButton.setTitle("CONFIRMED_SECRET_TITLE".localized(), for: .normal)
        } else {
            confirmationButton.setTitle("REVEAL_MNEMONIC_INFORMATION".localized(), for: .normal)
        }

        confirmationButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        confirmationButton.layer.cornerRadius = 5

        holderView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGray

        let navButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveToKeychain(_:)))
        navigationItem.rightBarButtonItem = navButton

        advancedSecurityButton.isHidden = mode.hideAdvancedSecurity

        collectionView.register(cellType: PillViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 4

            if !UIDevice.current.shortScreen {
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
                layout.minimumLineSpacing = 16
                layout.minimumInteritemSpacing = 8
            }
        }

        styleAdvancedSecurity()

        if mode == .view {
            holderView.addSubview(concealingView)
            holderView.constrainViewToAllEdges(concealingView)
            concealingView.backgroundColor = .clear
            concealingView.effect = blurEffect
        }
    }
}

// MARK: - IBActions / Actions
extension MnemonicViewController {
    @IBAction func selectedConfirmation(_ sender: Any) {
        if mode == .confirm {
            guard let mnemonic = self.mnemonic else { return }
            delegate?.confirmedWrittenMnemonic(self, mnemonic: mnemonic, passphrase: mnemonicPassphrase)
        } else {
            toggleVisibility(revealText: "REVEAL_MNEMONIC_INFORMATION".localized(),
                             concealText: "CONCEAL_MNEMONIC_INFORMATION".localized())
        }
    }

    @IBAction func selectedAdvancedSecurity(_ sender: Any) {
        self.clearPassphrase()
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

extension MnemonicViewController: UICollectionViewDelegate { }

extension MnemonicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let mnemonic = self.mnemonic else { return 0 }

        let count = mnemonic.words.count

        return mnemonicPassphrase != nil ? count + 1 : count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let pillCell: PillViewCell = collectionView.dequeueReusableCell(for: indexPath)

        guard let mnemonic = self.mnemonic else { return pillCell }

        if indexPath.row < mnemonic.words.count {
            let word = mnemonic.words[indexPath.row]
            pillCell.update(label: String(indexPath.row + 1), text: word)
        } else if let phrase = self.mnemonicPassphrase {
            pillCell.update(label: "PASSPHRASE_LABEL".localized(), text: phrase.string)
        }

        return pillCell
    }
}

// MARK: - Blurrable
extension MnemonicViewController: Blurrable {
    var blurContainerView: UIView? { return holderView }
    var toggleButton: UIButton? { return confirmationButton }
}
