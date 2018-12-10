//
//  ApplicationCoordinator+Wallet.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

// MARK: - WalletViewControllerDelegate
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
        guard let service = core?.accountService else { return }

        let sendVC = SendViewController(service: service, asset: asset)
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
        let transactionVC = TransactionDetailsViewController(effect: effect)
        transactionViewController = transactionVC
        transactionVC.delegate = self

        wrappingNavController?.pushViewController(transactionVC, animated: true)
    }
}

// MARK: - WalletSwitchingViewControllerDelegate
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

        core?.accountService.changeTrust(account: account, asset: asset, remove: true, delegate: walletVC)
    }

    func add(asset: StellarAsset) {
        guard let account = core?.accountService.account, let walletVC = walletSwitchingViewController  else {
            return
        }

        core?.accountService.changeTrust(account: account, asset: asset, remove: false, delegate: walletVC)
    }
}

// MARK: - AddAssetViewControllerDelegate
extension ApplicationCoordinator: AddAssetViewControllerDelegate {
    func requestedAdd(_ viewController: AddAssetViewController, asset: StellarAsset) {

        guard let account = core?.accountService.account, let walletVC = walletSwitchingViewController  else {
            return
        }

        walletVC.displayAddPrompt()

        core?.accountService.changeTrust(account: account, asset: asset, remove: false, delegate: walletVC)
    }
}

// MARK: - InflationViewControllerDelegate
extension ApplicationCoordinator: InflationViewControllerDelegate {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress) {
        guard let account = core?.accountService.account else {
            return
        }

        core?.accountService.setInflationDestination(account: account, address: destination, delegate: viewController)
    }
}

extension ApplicationCoordinator: TransactionDetailsViewControllerDelegate {
    func requestedTransaction(_ viewController: TransactionDetailsViewController,
                              for effect: StellarEffect) -> StellarTransaction? {
        return core?.indexingService.relatedObject(startingAt: effect)
    }

    func requestedOperations(_ viewController: TransactionDetailsViewController,
                             for transaction: StellarTransaction) -> [StellarOperation] {
        if let accountOperations = core?.accountService.account?.operations {
            return accountOperations.filter { $0.transactionHash == transaction.hash }
        }

        return []
    }
}
