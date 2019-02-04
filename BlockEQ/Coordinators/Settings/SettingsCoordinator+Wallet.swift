//
//  SettingsCoordinator+Pin.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-02-05.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Foundation

extension SettingsCoordinator {
    func fundTestnetAccount() {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated

        guard let account = self.core.accountService.account else { return }
        let fundOperation = FundTestnetAccountOperation(address: account.accountId)

        operationQueue.addOperation(fundOperation)
    }

    func clearWalletPrompt() {
        let alertController = UIAlertController(title: "CLEAR_WALLET_TITLE".localized(),
                                                message: nil,
                                                preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "CLEAR_WALLET_ACTION".localized(),
                                      style: .destructive,
                                      handler: { (_) -> Void in
                                        self.clearWallet()
        })

        let cancelButton = UIAlertAction(title: "CANCEL_ACTION".localized(),
                                         style: .default,
                                         handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        navWrapper.present(alertController, animated: true, completion: nil)
    }

    func clearWallet() {
        delegate?.requestedAuthentication(self, with: AuthenticationCoordinator.defaultConfirmationOptions,
                                          authorized: {
            self.delegate?.clearedWallet()
        })
    }

    func displayMnemonic() {
        let mnemonic = core.accountService.accountMnemonic()
        let phrase = core.accountService.accountPassphrase()
        let mnemonicViewController = MnemonicViewController(mnemonic: mnemonic, passphrase: phrase, mode: .view)

        navWrapper.pushViewController(mnemonicViewController, animated: true)
    }

    func displaySecretSeed() {
        var viewController: SecretSeedViewController

        if let seed = core.accountService.accountSecretSeed() {
            viewController = SecretSeedViewController(seed)
        } else if let mnemonic = core.accountService.accountMnemonic() {
            let passphrase = core.accountService.accountPassphrase()
            viewController = SecretSeedViewController(mnemonic: mnemonic, passphrase: passphrase)
        } else {
            return
        }

        navWrapper.pushViewController(viewController, animated: true)
    }

    func manageWallet(with node: SettingNode) {
        if node.identifier == "keys-display-secret-seed" {
            delegate?.requestedAuthentication(self, with: AuthenticationCoordinator.defaultConfirmationOptions,
                                              authorized: {
                                                self.displaySecretSeed()
            })
        } else if node.identifier == "keys-view-mnemonic" {
            delegate?.requestedAuthentication(self, with: AuthenticationCoordinator.defaultConfirmationOptions,
                                              authorized: {
                                                self.displayMnemonic()
            })
        }
    }
}
