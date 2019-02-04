//
//  ApplicationCoordinator+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

// MARK: - AuthenticationCoordinatorDelegate
extension ApplicationCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
        settingsCoordinator.restoreTemporaryPINSettings()

        authCompletion = nil
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        settingsCoordinator.restoreTemporaryPINSettings()

        KeychainHelper.clearAll()
        SecurityOptionHelper.clear()

        delegate?.switchToOnboarding()
        authCompletion = nil
    }

    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        authCompletion?()
        authCompletion = nil
    }
}

// MARK: - ContactsViewControllerDelegate
extension ApplicationCoordinator: ContactsViewControllerDelegate {
    func requestedSendPayment(contact: LocalContact) {
        guard let service = core.accountService, let account = core.accountService.account else { return }

        let paymentCoordinator = PaymentCoordinator(accountService: service, account: account, type: .contact(contact))
        paymentCoordinator?.delegate = self

        self.paymentCoordinator = paymentCoordinator

        guard let container = paymentCoordinator?.pay() else { return }

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedAddToAddressBook(identifier: String, name: String, address: String) {
        let stellarContactVC = StellarContactViewController(identifier: identifier, name: name, address: address)

        let container = AppNavigationController(rootViewController: stellarContactVC)
        container.navigationBar.prefersLargeTitles = true

        stellarContactViewController = stellarContactVC

        tabController.present(container, animated: true, completion: nil)
    }
}

// MARK: - PaymentCoordinatorDelegate
extension ApplicationCoordinator: PaymentCoordinatorDelegate {
    func requestedAuthentication(_ coordinator: AuthenticationCoordinatorDelegate,
                                 with options: AuthenticationCoordinator.AuthenticationOptions) {
        guard let viewController = paymentCoordinator?.navController else { return }
        delegate?.requestedAuthentication(coordinator, container: viewController, options: options)
    }

    func dismiss(_ coordinator: PaymentCoordinator, container: UIViewController) {
        container.dismiss(animated: true, completion: nil)
        paymentCoordinator = nil
    }
}

// MARK: - DiagnosticCoordinatorDelegate
extension ApplicationCoordinator: DiagnosticCoordinatorDelegate {
    func completedDiagnostic(_ coordinator: DiagnosticCoordinator) {
    }
}
