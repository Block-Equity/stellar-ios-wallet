//
//  ApplicationCoordinator+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

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
    func selectedSend(_ viewController: WalletViewController, account: StellarAccount, index: Int) {
        let sendVC = SendViewController(stellarAccount: account, currentAssetIndex: index)
        let container = AppNavigationController(rootViewController: sendVC)
        container.navigationBar.prefersLargeTitles = true

        sendViewController = sendVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedWalletSwitch(_ viewController: WalletViewController, account: StellarAccount) {
        let walletSwitchVC = WalletSwitchingViewController()
        let container = AppNavigationController(rootViewController: walletSwitchVC)
        container.navigationBar.prefersLargeTitles = true

        walletSwitchingViewController = walletSwitchVC
        walletSwitchVC.delegate = self
        walletSwitchVC.updateMenu(stellarAccount: account)

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedReceive(_ viewController: WalletViewController, account: StellarAccount) {
        let address = account.accountId
        let receiveVC = ReceiveViewController(address: address, isPersonalToken: false)
        let container = AppNavigationController(rootViewController: receiveVC)
        container.navigationBar.prefersLargeTitles = true

        receiveViewController = receiveVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectBalance(account: StellarAccount, index: Int) {
        let balanceVC = BalanceViewController(stellarAccount: account, stellarAsset: account.assets[index])
        let container = AppNavigationController(rootViewController: balanceVC)
        container.navigationBar.prefersLargeTitles = true

        balanceViewController = balanceVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedEffect(_ viewController: WalletViewController, effect: StellarEffect) {
        let transactionVC = TransactionDetailsViewController(effect)
        transactionViewController = transactionVC
        wrappingNavController?.pushViewController(transactionVC, animated: true)
    }
}

extension ApplicationCoordinator: WalletSwitchingViewControllerDelegate {
    func didSelectSetInflation(inflationDestination: String?) {
        let inflationViewController = InflationViewController(inflationDestination: inflationDestination)
        self.inflationViewController = inflationViewController

        wrappingNavController?.pushViewController(inflationViewController, animated: true)
    }

    func didSelectAddAsset() {
        let addAssetViewController = AddAssetViewController()
        addAssetViewController.delegate = self
        self.addAssetViewController = addAssetViewController

        wrappingNavController?.pushViewController(addAssetViewController, animated: true)
    }

    func didSelectAsset(index: Int) {
        walletViewController.selectAsset(at: index)
    }

    func reloadAssets() {
        walletViewController.getAccountDetails()
    }
}

extension ApplicationCoordinator: AddAssetViewControllerDelegate {
    func didAddAsset(stellarAccount: StellarAccount) {
        reloadAssets()

        walletSwitchingViewController?.updateMenu(stellarAccount: stellarAccount)
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
