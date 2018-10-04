//
//  OnboardingCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import stellarsdk

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCompleted()
}

final class OnboardingCoordinator {
    let navController: AppNavigationController
    let launchViewController = LaunchViewController()
    let verificationViewController = VerificationViewController(type: .recovery, mnemonic: nil)
    var mnemonicViewController: MnemonicViewController?

    weak var delegate: OnboardingCoordinatorDelegate?
    var authenticationCoordinator: AuthenticationCoordinator?
    var mnemonic: RecoveryMnemonic?
    var secretSeed: SecretSeed?

    init() {
        navController = AppNavigationController(rootViewController: launchViewController)
        navController.navigationBar.prefersLargeTitles = true
        verificationViewController.delegate = self
        launchViewController.delegate = self
    }

    func authenticate() {
        let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: false,
                                                                   presentVC: false,
                                                                   forcedStyle: nil,
                                                                   limitPinEntries: true)
        let authCoordinator = AuthenticationCoordinator(container: self.navController, options: opts)
        authCoordinator.delegate = self
        authenticationCoordinator = authCoordinator
        authCoordinator.createPinAuthentication()
    }
}

extension OnboardingCoordinator: LaunchViewControllerDelegate {
    func requestedCreateNewWallet(_ viewController: LaunchViewController, type: RecoveryMnemonic.MnemonicType) {
        var mnemonic: String

        switch type {
        case .twelve:
            mnemonic = Wallet.generate12WordMnemonic()
        case .twentyFour:
            mnemonic = Wallet.generate24WordMnemonic()
        }

        let mnemonicVC = MnemonicViewController(mnemonic: mnemonic, shouldSetPin: false, hideConfirmation: false)
        mnemonicVC.delegate = self

        self.mnemonicViewController = mnemonicVC

        navController.pushViewController(mnemonicVC, animated: true)
    }

    func requestedImportWallet(_ viewController: LaunchViewController) {
        navController.pushViewController(verificationViewController, animated: true)
    }
}

extension OnboardingCoordinator: MnemonicViewControllerDelegate {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController, mnemonic: RecoveryMnemonic) {
        self.mnemonic = mnemonic
        authenticate()
    }
}

extension OnboardingCoordinator: VerificationViewControllerDelegate {
    func validatedAccount(_ viewController: VerificationViewController, mnemonic: RecoveryMnemonic) {
        self.mnemonic = mnemonic
        authenticate()
    }

    func validatedAccount(_ viewController: VerificationViewController, secret: SecretSeed) {
        self.secretSeed = secret
        authenticate()
    }
}

extension OnboardingCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
        assert(false, "You shouldn't be able to dismiss the PIN entry during onboarding. Fix this!")
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        print("Failed pin during on boarding")
        KeychainHelper.clearAll()
        SecurityOptionHelper.clear()
        verificationViewController.navigationController?.popToRootViewController(animated: true)
        authenticationCoordinator = nil

    }

    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        if let mnemonic = self.mnemonic {
            save(mnemonic: mnemonic)
        } else if let secret = self.secretSeed {
            save(secret: secret)
        }

        authenticationCoordinator = nil
        delegate?.onboardingCompleted()
    }
}

extension OnboardingCoordinator {
    func save(mnemonic: RecoveryMnemonic) {
        if let keyPair = try? Wallet.createKeyPair(mnemonic: mnemonic.string, passphrase: nil, index: 0) {
            setPrivateData(keyPair: keyPair, mnemonic: mnemonic.string)
        }
    }

    func save(secret: SecretSeed) {
        if let keyPair = try? KeyPair(secretSeed: secret.string) {
            setPrivateData(keyPair: keyPair, seed: secret.string)
        }
    }

    private func setPrivateData(keyPair: KeyPair, mnemonic: String? = nil, seed: String? = nil) {
        let privateBytes = keyPair.privateKey?.bytes ?? [UInt8]()
        let privateKeyData = Data(bytes: privateBytes)
        let publicKeyData = Data(bytes: keyPair.publicKey.bytes)

        KeychainHelper.setExistingInstance()
        KeychainHelper.save(accountId: keyPair.accountId)
        KeychainHelper.save(publicKey: publicKeyData)
        KeychainHelper.save(privateKey: privateKeyData)

        if let mnemonic = mnemonic {
            KeychainHelper.save(mnemonic: mnemonic)
        }

        if let seed = seed {
            KeychainHelper.save(seed: seed)
        }
    }
}
