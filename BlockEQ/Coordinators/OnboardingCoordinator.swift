//
//  OnboardingCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCompleted(service: CoreService)
}

final class OnboardingCoordinator {
    let navController: AppNavigationController
    let launchViewController = LaunchViewController()
    let verificationViewController = VerificationViewController(type: .recovery, mnemonic: nil)
    var mnemonicViewController: MnemonicViewController?

    weak var delegate: OnboardingCoordinatorDelegate?
    var authenticationCoordinator: AuthenticationCoordinator?
    var core: CoreService!

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
    func requestedCreateNewWallet(_ viewController: LaunchViewController, type: StellarRecoveryMnemonic.MnemonicType) {

        core.accountService.clear()

        guard let mnemonic = StellarRecoveryMnemonic.generate(type: type) else {
            UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                          message: "MNEMONIC_GENERATION_ERROR".localized(),
                                          presentingViewController: viewController)
            return
        }

        let mnemonicVC = MnemonicViewController(mnemonic: mnemonic, mode: .confirm)
        mnemonicVC.delegate = self

        self.mnemonicViewController = mnemonicVC
        navController.pushViewController(mnemonicVC, animated: true)
    }

    func requestedImportWallet(_ viewController: LaunchViewController) {
        navController.pushViewController(verificationViewController, animated: true)
    }
}

extension OnboardingCoordinator: MnemonicViewControllerDelegate {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController,
                                  mnemonic: StellarRecoveryMnemonic,
                                  passphrase: StellarMnemonicPassphrase?) {
        do {
            try core.accountService.initializeAccount(with: mnemonic, passphrase: passphrase)

            if let account = core.accountService?.account {
                CacheManager.cacheAccountQRCode(account)
            }
        } catch {
            core.accountService.clear()
            UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                          message: "MNEMONIC_GENERATION_ERROR".localized(),
                                          presentingViewController: navController)
            return
        }

        recordWalletDiagnostic(mnemonic: mnemonic, recovered: false, passphrase: passphrase != nil)
        authenticate()
    }
}

extension OnboardingCoordinator: VerificationViewControllerDelegate {
    func validatedAccount(_ viewController: VerificationViewController,
                          mnemonic: StellarRecoveryMnemonic,
                          passphrase: StellarMnemonicPassphrase?) {
        save(mnemonic: mnemonic, recovered: true, passphrase: passphrase)
        authenticate()
    }

    func validatedAccount(_ viewController: VerificationViewController, secret: StellarSeed) {
        save(secret: secret)
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
        authenticationCoordinator = nil

        if let account = core.accountService.account {
            KeychainHelper.save(accountId: account.accountId)
        }

        KeychainHelper.setExistingInstance()

        delegate?.onboardingCompleted(service: core)
    }
}

extension OnboardingCoordinator {
    func recordWalletDiagnostic(mnemonic: StellarRecoveryMnemonic, recovered: Bool, passphrase: Bool) {
        guard let accountId = core.accountService.account?.accountId else { return }

        let creationMethod = WalletDiagnostic.CreationMethod.from(mnemonic: mnemonic, recovered: recovered)
        let diagnostic = WalletDiagnostic(address: accountId,
                                          creationMethod: creationMethod,
                                          usesPassphrase: passphrase)

        KeychainHelper.setDiagnostic(diagnostic)
    }

    func save(mnemonic: StellarRecoveryMnemonic, recovered: Bool, passphrase: StellarMnemonicPassphrase?) {
        do {
            try core.accountService.initializeAccount(with: mnemonic, passphrase: passphrase)

            if let account = core.accountService?.account {
                CacheManager.cacheAccountQRCode(account)
            }

            recordWalletDiagnostic(mnemonic: mnemonic, recovered: recovered, passphrase: passphrase != nil)
        } catch {
            // error
        }
    }

    func save(secret: StellarSeed) {
        do {
            try core.accountService.initializeAccount(with: secret)

            guard let account = core.accountService.account else { return }

            CacheManager.cacheAccountQRCode(account)

            let diagnostic = WalletDiagnostic(address: account.accountId,
                                              creationMethod: .recoveredSeed,
                                              usesPassphrase: false)

            KeychainHelper.setDiagnostic(diagnostic)
        } catch {
            // error
        }
    }
}
