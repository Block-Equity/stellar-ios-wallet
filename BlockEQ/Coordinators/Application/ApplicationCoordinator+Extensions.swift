//
//  ApplicationCoordinator+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

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

// MARK: - AccountManagementServiceDelegate
extension ApplicationCoordinator: AccountManagementServiceDelegate {
    func accountSwitched(_ service: AccountManagementService, account: StellarAccount) {
        // ?
    }
}

// MARK: - AccountUpdateServiceDelegate
extension ApplicationCoordinator: AccountUpdateServiceDelegate {
    func firstAccountUpdate(_ service: AccountUpdateService, account: StellarAccount) {
        core?.streamService.subscribeAll(account: account)
    }

    func accountUpdated(_ service: AccountUpdateService,
                        account: StellarAccount,
                        options: AccountUpdateService.UpdateOptions) {
        if options.contains(.effects) || options.contains(.account) {
            walletViewController.updated(account: account)
            KeychainHelper.setHasFetchedData()
        }

        tradingCoordinator?.updated(account: account)
        balanceViewController?.updated(account: account)
    }
}

// MARK: - DiagnosticCoordinatorDelegate
extension ApplicationCoordinator: DiagnosticCoordinatorDelegate {
    func completedDiagnostic(_ coordinator: DiagnosticCoordinator) {
    }
}

// MARK: - StreamServiceDelegate
extension ApplicationCoordinator: StreamServiceDelegate {
    func streamError(service: StreamService, stream: StreamService.StreamType, error: FrameworkError) {
        if error.errorCategory == .stellar {
            try? service.unsubscribe(from: stream)
        }
    }

    func receivedObjects(stream: StreamService.StreamType) {
        core?.updateService.update()
    }
}
