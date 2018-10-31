//
//  ApplicationCoordinator+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

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

extension ApplicationCoordinator: WalletViewControllerDelegate {
    func selectedWalletSwitch(_ viewController: WalletViewController) {
        guard let account = core?.accountService.account else { return }

        let walletSwitchVC = WalletSwitchingViewController()
        let container = AppNavigationController(rootViewController: walletSwitchVC)
        container.navigationBar.prefersLargeTitles = true
        walletViewController.navigationContainer = container

        walletSwitchingViewController = walletSwitchVC

        walletSwitchVC.delegate = self
        walletSwitchVC.updateMenu(account: account)

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedSend(_ viewController: WalletViewController, for asset: StellarAsset) {
        guard let account = core?.accountService.account else { return }

        let sendVC = SendViewController(stellarAccount: account, asset: asset)
        let container = AppNavigationController(rootViewController: sendVC)
        container.navigationBar.prefersLargeTitles = true

        sendViewController = sendVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedReceive(_ viewController: WalletViewController) {
        guard let account = core?.accountService.account else { return }

        let address = account.accountId
        let receiveVC = ReceiveViewController(address: address, isPersonalToken: false)
        let container = AppNavigationController(rootViewController: receiveVC)
        container.navigationBar.prefersLargeTitles = true

        receiveViewController = receiveVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectBalance(_ viewController: WalletViewController, for asset: StellarAsset) {
        guard let account = core?.accountService.account else { return }

        let balanceVC = BalanceViewController(stellarAccount: account, stellarAsset: asset)
        let container = AppNavigationController(rootViewController: balanceVC)
        container.navigationBar.prefersLargeTitles = true

        balanceViewController = balanceVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedEffect(_ viewController: WalletViewController, effect: StellarEffect) {
        let transactionVC = TransactionDetailsViewController()
        transactionViewController = transactionVC

//        transactionVC.update(with: TransactionDetailsViewController.EffectViewModel(
//            sourceAccount: "???",
//            transactionId: "???",
//            date: Date(),
//            sequenceNumber: "293478239874329",
//            fee: "0.01 XLM",
//            memo: "This is the memo data",
//            memoType: "TEXT",
//            operations: [],
//            signatures: []
//        ))

        wrappingNavController?.pushViewController(transactionVC, animated: true)
    }
}

extension ApplicationCoordinator: WalletSwitchingViewControllerDelegate {
    func selectedAddAsset() {
        let addAssetViewController = AddAssetViewController()
        self.addAssetViewController = addAssetViewController
        addAssetViewController.delegate = self

        if let container = walletViewController.navigationContainer {
            container.pushViewController(addAssetViewController, animated: true)
        } else {
            wrappingNavController?.pushViewController(addAssetViewController, animated: true)
        }
    }

    func updateInflation() {
        guard let account = core?.accountService.account else { return }

        let inflationViewController = InflationViewController(account: account)
        self.inflationViewController = inflationViewController
        self.inflationViewController?.delegate = self

        if let container = walletViewController.navigationContainer {
            container.pushViewController(inflationViewController, animated: true)
        } else {
            wrappingNavController?.pushViewController(inflationViewController, animated: true)
        }
    }

    func switchWallet(to asset: StellarAsset) {
        guard let account = core?.accountService.account else { return }
        walletViewController.update(with: account, asset: asset)
    }

    func createTrustLine(to address: StellarAddress, for asset: StellarAsset) { }

    func reloadAssets() { }

    func remove(asset: StellarAsset) {
        guard let account = core?.accountService.account, let walletVC = walletSwitchingViewController else {
            return
        }

        account.changeTrust(asset: asset, remove: true, delegate: walletVC)
    }

    func add(asset: StellarAsset) {
        guard let account = core?.accountService.account, let walletVC = walletSwitchingViewController  else {
            return
        }

        account.changeTrust(asset: asset, remove: false, delegate: walletVC)
    }
}

extension ApplicationCoordinator: InflationViewControllerDelegate {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress) {
        guard let account = core?.accountService.account else {
            return
        }

        account.setInflationDestination(address: destination, delegate: viewController)
    }
}

extension ApplicationCoordinator: AddAssetViewControllerDelegate {
    func requestedAdd(_ viewController: AddAssetViewController, asset: StellarAsset) {

        guard let account = core?.accountService.account, let walletVC = walletSwitchingViewController  else {
            return
        }

        walletVC.displayAddPrompt()

        account.changeTrust(asset: asset, remove: false, delegate: walletVC)
    }
}

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

extension ApplicationCoordinator: StellarAccountServiceDelegate {
    func accountUpdated(_ service: StellarAccountService, account: StellarAccount, opts: StellarAccount.UpdateOptions) {
        if opts.contains(.effects) || opts.contains(.account) {
            self.walletViewController.update(account: account)
            self.contactsViewController.update(account: account)
        }

        self.tradingCoordinator.update(account: account)
    }

    func accountInactive(_ service: StellarAccountService, account: StellarAccount) {
        self.walletViewController.update(account: account)
        self.contactsViewController.update(account: account)
        self.tradingCoordinator.update(account: account)
    }

    func paymentUpdate(_ service: StellarAccountService, operation: StellarOperation) {
        service.update()
    }
}
