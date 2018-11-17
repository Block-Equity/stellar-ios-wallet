//
//  ApplicationCoordinator+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

// MARK: - AuthenticationCoordinatorDelegate
extension ApplicationCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
        // We need to re-set the previously switched setting, in the case the user cancels the authentication challenge
        SecurityOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)
        SecurityOptionHelper.set(option: .useBiometrics, value: temporaryBiometricSetting)

        settingsViewController.tableView?.reloadData()
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        // We need to re-set the previously switched setting, in the case the user cancels the authentication challenge
        SecurityOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)
        SecurityOptionHelper.set(option: .useBiometrics, value: temporaryBiometricSetting)

        settingsViewController.tableView?.reloadData()

        KeychainHelper.clearAll()
        SecurityOptionHelper.clear()

        self.delegate?.switchToOnboarding()

        authenticationCoordinator = nil
    }

    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        authenticationCoordinator = nil

        authCompletion?()
        authCompletion = nil
    }
}

// MARK: - ContactsViewControllerDelegate
extension ApplicationCoordinator: ContactsViewControllerDelegate {
    func selectedAddToAddressBook(identifier: String, name: String, address: String) {
        let stellarContactVC = StellarContactViewController(identifier: identifier, name: name, address: address)
        let container = AppNavigationController(rootViewController: stellarContactVC)

        stellarContactViewController = stellarContactVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true

        tabController.present(container, animated: true, completion: nil)
    }
}

// MARK: - StellarAccountServiceDelegate
extension ApplicationCoordinator: StellarAccountServiceDelegate {
    func accountUpdated(_ service: StellarAccountService,
                        account: StellarAccount,
                        opts: StellarAccountService.UpdateOptions) {
        if opts.contains(.effects) || opts.contains(.account) {
            self.walletViewController.updated(account: account)
        }

        self.tradingCoordinator.updated(account: account)
    }

    func accountInactive(_ service: StellarAccountService, account: StellarAccount) {
        self.walletViewController.updated(account: account)
        self.tradingCoordinator.updated(account: account)
    }

    func paymentUpdate(_ service: StellarAccountService, operation: StellarOperation) {
        service.update()
    }
}

// MARK: - DiagnosticCoordinatorDelegate
extension ApplicationCoordinator: DiagnosticCoordinatorDelegate {
    func completedDiagnostic(_ coordinator: DiagnosticCoordinator) {
    }
}
