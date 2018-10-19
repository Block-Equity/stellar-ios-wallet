//
//  OnboardingCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCompleted(service: StellarCoreService)
}

final class OnboardingCoordinator {
    let navController: AppNavigationController
    let launchViewController = LaunchViewController()
    let verificationViewController = VerificationViewController(type: .recovery, mnemonic: nil)
    var mnemonicViewController: MnemonicViewController?

    weak var delegate: OnboardingCoordinatorDelegate?
    var authenticationCoordinator: AuthenticationCoordinator?
    var core: StellarCoreService

    init() {
        navController = AppNavigationController(rootViewController: launchViewController)
        navController.navigationBar.prefersLargeTitles = true

        core = StellarCoreService(with: .production)

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
        guard let mnemonic = StellarRecoveryMnemonic.generate(type: type) else {
            UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                          message: "MNEMONIC_GENERATION_ERROR".localized(),
                                          presentingViewController: viewController)
            return
        }

        do {
            try core.accountService.initializeAccount(with: mnemonic)

            let mnemonicVC = MnemonicViewController(mnemonic: mnemonic, shouldSetPin: false, hideConfirmation: false)
            mnemonicVC.delegate = self

            self.mnemonicViewController = mnemonicVC
            navController.pushViewController(mnemonicVC, animated: true)
        } catch {
            UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                          message: "MNEMONIC_GENERATION_ERROR".localized(),
                                          presentingViewController: navController)
        }
    }

    func requestedImportWallet(_ viewController: LaunchViewController) {
        navController.pushViewController(verificationViewController, animated: true)
    }
}

extension OnboardingCoordinator: MnemonicViewControllerDelegate {
    func confirmedWrittenMnemonic(_ viewController: MnemonicViewController, mnemonic: StellarRecoveryMnemonic) {
        authenticate()
    }
}

extension OnboardingCoordinator: VerificationViewControllerDelegate {
    func validatedAccount(_ viewController: VerificationViewController, mnemonic: StellarRecoveryMnemonic) {
        save(mnemonic: mnemonic)
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
        KeychainHelper.setExistingInstance()

        if let account = core.accountService.account {
            KeychainHelper.save(accountId: account.accountId)
        }

        delegate?.onboardingCompleted(service: core)
    }
}

extension OnboardingCoordinator {
    func save(mnemonic: StellarRecoveryMnemonic) {
        do {
            try core.accountService.initializeAccount(with: mnemonic)

        } catch {
            // error
        }
    }

    func save(secret: StellarSeed) {
        do {
            try core.accountService.initializeAccount(with: secret)
        } catch {
            // error
        }
    }
}
