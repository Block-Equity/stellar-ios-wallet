//
//  OnboardingCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-19.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation
import stellarsdk

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCompleted()
}

final class OnboardingCoordinator {
    let navController: AppNavigationController
    let launchViewController = LaunchViewController()
    let verificationViewController = VerificationViewController(type: .recovery, mnemonic: "")
    var mnemonicViewController: MnemonicViewController?

    weak var delegate: OnboardingCoordinatorDelegate?
    var authenticationCoordinator: AuthenticationCoordinator?

    init() {
        navController = AppNavigationController(rootViewController: launchViewController)
        navController.navigationBar.prefersLargeTitles = true
        verificationViewController.delegate = self
        launchViewController.delegate = self
    }

    func authenticate() {
        if let authCoordinator = self.authenticationCoordinator {
            authCoordinator.createPinAuthentication()
        } else {
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
}

extension OnboardingCoordinator: LaunchViewControllerDelegate {
    func requestedCreateNewWallet(_ vc: LaunchViewController, type: MnemonicType) {
        let mnemonicVC = MnemonicViewController(mnemonic: nil, shouldSetPin: false, hideConfirmation: false, mnemonicType: type)
        mnemonicVC.delegate = self
        
        self.mnemonicViewController = mnemonicVC
        
        navController.pushViewController(mnemonicVC, animated: true)
    }

    func requestedImportWallet(_ vc: LaunchViewController) {
        navController.pushViewController(verificationViewController, animated: true)
    }
}

extension OnboardingCoordinator: MnemonicViewControllerDelegate {
    func confirmedWrittenMnemonic(_ vc: MnemonicViewController, mnemonic: String) {
        saveMnemonic(mnemonic: mnemonic)
        authenticate()
    }
}

extension OnboardingCoordinator: VerificationViewControllerDelegate {
    func validatedAccount(_ vc: VerificationViewController, mnemonic: String) {
        saveMnemonic(mnemonic: mnemonic)
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
        delegate?.onboardingCompleted()
    }
}

extension OnboardingCoordinator {
    func saveMnemonic(mnemonic: String) {
        let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0)

        let publicKeyData = NSData(bytes: keyPair.publicKey.bytes, length: keyPair.publicKey.bytes.count) as Data
        let privateBytes = keyPair.privateKey?.bytes ?? [UInt8]()
        let privateKeyData = NSData(bytes: privateBytes, length: privateBytes.count) as Data

        KeychainHelper.setExistingInstance()
        KeychainHelper.save(mnemonic: mnemonic)
        KeychainHelper.save(accountId: keyPair.accountId)
        KeychainHelper.save(publicKey: publicKeyData)
        KeychainHelper.save(privateKey: privateKeyData)
    }
}
