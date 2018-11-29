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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var advancedSecurityButton: UIButton!
    @IBOutlet weak var confirmationButton: AppButton!

    weak var delegate: MnemonicViewControllerDelegate?

    var mnemonic: StellarRecoveryMnemonic?
    var hideConfirmation: Bool = false
    var hideAdvancedSecurity: Bool = true

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

    init(mnemonic: StellarRecoveryMnemonic?,
         passphrase: StellarMnemonicPassphrase? = nil,
         hideConfirmation: Bool = false,
         advancedSecurity: Bool = false) {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)
        self.hideConfirmation = hideConfirmation
        self.hideAdvancedSecurity = !advancedSecurity
        self.mnemonic = mnemonic
        self.mnemonicPassphrase = passphrase
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = mnemonic != nil ? "MNEMONIC_REMINDER_MESSAGE".localized() : "NO_MNEMONIC_SET".localized()
        self.confirmationButton.isHidden = self.hideConfirmation

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

        collectionView.registerCell(type: PillViewCell.self)
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
    }
}

// MARK: - IBActions / Actions
extension MnemonicViewController {
    @IBAction func confirmedWrittenDown(_ sender: Any) {
        guard let mnemonic = self.mnemonic else { return }
        delegate?.confirmedWrittenMnemonic(self, mnemonic: mnemonic, passphrase: mnemonicPassphrase)
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
