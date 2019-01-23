//
//  UIViewController+AdvancedSecurity.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol PassphrasePromptable: AnyObject {
    var temporaryPassphrase: StellarMnemonicPassphrase? { get set }
    var mnemonicPassphrase: StellarMnemonicPassphrase? { get set }
    var passphraseButton: UIButton { get }
}

extension PassphrasePromptable where Self: UIViewController {
    func styleAdvancedSecurity() {
        passphraseButton.setTitle("ADVANCED_SECURITY_TITLE".localized(), for: .normal)
        passphraseButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        passphraseButton.setTitleColor(Colors.darkGrayTransparent, for: .normal)
    }

    func passphrasePrompt(confirm: Bool, completion: @escaping (StellarMnemonicPassphrase?) -> Void) {
        let handler: (UIAlertController) -> Void = { controller in
            let passphrase = StellarMnemonicPassphrase(controller.textFields?[0].text)
            completion(passphrase)
        }

        let title = confirm ? "CONFIRM_PASSPHRASE_TITLE".localized() : "MNEMONIC_PASSPHRASE_TITLE".localized()
        let message = confirm ? "CONFIRM_PASSPHRASE_MESSAGE".localized() : "MNEMONIC_PASSPHRASE_MESSAGE".localized()

        UIAlertController.prompt(title: title,
                                 message: message,
                                 handler: handler,
                                 presentingViewController: self,
                                 placeholder: "ENTER_PASSPHRASE_PLACEHOLDER".localized(),
                                 secureText: true)
    }

    func mismatchedPrompt() {
        UIAlertController.simpleAlert(title: "MISMATCHED_PASSPHRASE_TITLE".localized(),
                                      message: "MISMATCHED_PASSPHRASE_MESSAGE".localized(),
                                      presentingViewController: self)
    }

    func invalidPrompt() {
        UIAlertController.simpleAlert(title: "INVALID_PASSPHRASE_TITLE".localized(),
                                      message: "INVALID_PASSPHRASE_MESSAGE".localized(),
                                      presentingViewController: self)
    }

    func updatePassphraseSet(with phrase: StellarMnemonicPassphrase ) {
        passphraseButton.setTitle("PASSPHRASE_SET".localized(), for: .normal)
        self.mnemonicPassphrase = temporaryPassphrase
        self.temporaryPassphrase = nil
    }

    func clearPassphrase() {
        passphraseButton.setTitle("ADVANCED_SECURITY_TITLE".localized(), for: .normal)
        self.temporaryPassphrase = nil
        self.mnemonicPassphrase = nil
    }

    func setPassphrase(with phrase: StellarMnemonicPassphrase?) {
        guard let passphrase = phrase else {
            clearPassphrase()
            invalidPrompt()
            return
        }

        if let original = self.temporaryPassphrase, original == passphrase {
            updatePassphraseSet(with: passphrase)
        } else if let original = self.temporaryPassphrase, original != passphrase {
            clearPassphrase()
            mismatchedPrompt()
        } else {
            let confirmationCallback: (StellarMnemonicPassphrase?) -> Void = { string in
                self.setPassphrase(with: string)
            }

            self.temporaryPassphrase = passphrase
            self.passphrasePrompt(confirm: true, completion: confirmationCallback)
        }
    }
}

extension MnemonicViewController: PassphrasePromptable {
    var passphraseButton: UIButton { return self.advancedSecurityButton }
}

extension VerificationViewController: PassphrasePromptable {
    var passphraseButton: UIButton { return self.advancedSecurityButton }
}
