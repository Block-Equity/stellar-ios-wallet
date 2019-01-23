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
        guard let core = self.core, let account = core.accountService.account else {
            return
        }

        assetCoordinator = AssetCoordinator(accountService: core.accountService, account: account)
        assetCoordinator?.delegate = self

        guard let container = assetCoordinator?.displayAssetList() else {
            return
        }

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedSend(_ viewController: WalletViewController, for asset: StellarAsset) {
        guard let service = core?.accountService, let account = service.account else { return }

        let paymentCoordinator = PaymentCoordinator(accountService: service, account: account, type: .wallet(asset))
        paymentCoordinator?.delegate = self

        self.paymentCoordinator = paymentCoordinator

        guard let container = paymentCoordinator?.pay() else { return }

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedReceive(_ viewController: WalletViewController) {
        guard let account = core?.accountService.account else { return }

        let address = account.accountId
        let receiveVC = ReceiveViewController(address: address)
        let container = AppNavigationController(rootViewController: receiveVC)
        container.navigationBar.prefersLargeTitles = true

        receiveViewController = receiveVC

        tabController.present(container, animated: true, completion: nil)
    }

    func selectBalance(_ viewController: WalletViewController, for asset: StellarAsset) {
        guard let account = core?.accountService.account else { return }

        let balanceVC = BalanceViewController()
        let container = AppNavigationController(rootViewController: balanceVC)
        container.navigationBar.prefersLargeTitles = true

        balanceViewController = balanceVC
        balanceVC.delegate = self
        balanceVC.update(with: asset, account: account)

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedEffect(_ viewController: WalletViewController, effect: StellarEffect) {
        let transactionVC = TransactionDetailsViewController(effect: effect)
        transactionViewController = transactionVC
        transactionVC.delegate = self

        wrappingNavController?.pushViewController(transactionVC, animated: true)
    }

    func selectLearnMore(_ viewController: WalletViewController) {
        print("Learn more")
    }
}

extension ApplicationCoordinator: AssetCoordinatorDelegate {
    func added(asset: StellarAsset, account: StellarAccount) {
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
    }

    func selected(asset: StellarAsset) {
        guard let account = core?.accountService.account else { return }
        walletViewController.update(with: account, asset: asset)
    }

    func dismissed(coordinator: AssetCoordinator, viewController: UIViewController) {
        assetCoordinator = nil
    }

    func dataSource() -> AssetListDataSource? {
        guard let account = core?.accountService.account else {
            return nil
        }

        return AccountAssetListDataSource(accountAssets: account.assets,
                                          availableAssets: account.availableAssets,
                                          inflationSet: account.inflationAddress != nil)
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

extension ApplicationCoordinator: BalanceViewControllerDelegate {
    func dismiss(_ viewController: BalanceViewController) {
        balanceViewController?.dismiss(animated: true, completion: {
            self.balanceViewController = nil
        })
    }
}
