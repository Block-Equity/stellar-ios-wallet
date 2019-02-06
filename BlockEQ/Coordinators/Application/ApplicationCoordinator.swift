//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import WebKit
import Repeat
import os.log

protocol ApplicationCoordinatorDelegate: AnyObject {
    func switchToOnboarding()
    func requestedAuthentication(_ coordinator: AuthenticationCoordinatorDelegate,
                                 container: UIViewController,
                                 options: AuthenticationCoordinator.AuthenticationOptions)
}

final class ApplicationCoordinator {
    /// The controller class that directs which view controller is currently displayed
    let tabController = AppTabController(tab: .assets)

    /// The current visible view controller
    var currentViewController = UIViewController()

    // The coordinator responsible for listing, managing, and displaying assets
    var assetCoordinator: AssetCoordinator?

    // The coordinator responsible for managing the payment flow
    var paymentCoordinator: PaymentCoordinator?

    /// The service object that manages interactions with the Stellar network
    var core: CoreService

    /// The view controller used to display the minimum balance, deallocated once finished using
    var balanceViewController: BalanceViewController?

    /// The view controller used to display transaction details, deallocated once finished using
    var transactionViewController: TransactionDetailsViewController?

    /// The view controller responsible for adding and editing Stellar Contacts
    var stellarContactViewController: StellarContactViewController?

    /// The completion handler to call when the pin view controller completes successfully
    var authCompletion: EmptyCompletion?

    // A safety object to throttle how many requests to update data we make when receiving stream objects
    lazy var streamUpdateThrottler: Throttler = {
        return Throttler(time: .seconds(5), { [unowned self] in
            self.core.updateService.update()
        })
    }()

    // The coordinator responsible for the trading flow
    lazy var tradingCoordinator: TradingCoordinator = {
        let tradingCoordinator = TradingCoordinator(core: core)
        return tradingCoordinator
    }()

    // The coordinator responsible for helping manage settings
    lazy var settingsCoordinator: SettingsCoordinator = {
        let settingsCoordinator = SettingsCoordinator(core: core)
        settingsCoordinator.delegate = self

        return settingsCoordinator
    }()

    /// The view controller used for receiving funds
    var receiveViewController: ReceiveViewController?

    /// The view controller used to list out the user's assets
    lazy var walletViewController: WalletViewController = {
        let walletVC = WalletViewController()
        self.walletViewController = walletVC

        _ = walletVC.view

        walletVC.delegate = self

        return walletVC
    }()

    //The view controller responsible for displaying contacts
    lazy var contactsViewController: ContactsViewController = {
        let contactsVC = ContactsViewController(service: core.accountService)
        contactsVC.delegate = self

        return contactsVC
    }()

    /// Wrapping navigation controller for wallet view controller (which doesn't have a coordinator yet)
    lazy var contactsNavWrapper: AppNavigationController = {
        let wrapper = AppNavigationController(rootViewController: self.contactsViewController)
        return wrapper
    }()

    /// Wrapping navigation controller for contacts view controller (which doesn't have a coordinator)
    lazy var walletNavWrapper: AppNavigationController = {
        let wrapper = AppNavigationController(rootViewController: self.walletViewController)
        return wrapper
    }()

    weak var delegate: ApplicationCoordinatorDelegate?

    init(with coreService: CoreService) {
        core = coreService

        guard let accountId = KeychainHelper.accountId, let address = StellarAddress(accountId) else {
            return
        }

        core.accountService.registerForUpdates(self)
        core.updateService.registerForUpdates(self)
        core.streamService.delegate = self

        migrateIfEligible(using: core.accountService)
        try? core.accountService.restore(with: address)

        core.updateService.update()

        guard let account = core.accountService.account else { return }

        if account.isStub {
            core.updateService.accountUpdateInterval = AccountUpdateService.shortUpdateInterval
        }

        tabController.tabDelegate = self

        walletViewController.update(with: account, asset: StellarAsset.lumens)
    }

    func migrateIfEligible(using service: AccountManagementService) {
        if KeychainHelper.canMigrateToNewFormat,
            let accountId = KeychainHelper.accountId,
            let address = StellarAddress(accountId) {
            try? service.migrateAccount(with: address,
                                        mnemonicKey: KeychainHelper.mnemonicKey,
                                        seedKey: KeychainHelper.secretSeedKey,
                                        pubKey: KeychainHelper.publicSeedKey,
                                        privKey: KeychainHelper.privateSeedKey)

            WalletDiagnostic.extractFromKeychain()
            KeychainHelper.clearStellarSecrets()
        }
    }

    func displayAuth(_ completion: EmptyCompletion? = nil) {
        settingsCoordinator.storeTemporaryPINSettings()

        authCompletion = completion

        delegate?.requestedAuthentication(self,
                                          container: tabController,
                                          options: AuthenticationCoordinator.defaultConfirmationOptions)
    }

    func clearedWallet() {
        self.tradingCoordinator.stopPeriodicOrderbookUpdates()

        KeychainHelper.clearAll()
        SecurityOptionHelper.clear()
        CacheManager.shared.clearAccountCache()

        self.delegate?.switchToOnboarding()

        self.switchedTabs(.assets)
        self.walletViewController.clear()

        self.core.accountService.clear()
        self.core.stopSubservices()
    }
}

extension ApplicationCoordinator: AppTabControllerDelegate {
    func switchedTabs(_ appTab: ApplicationTab) {
        var viewController: AppNavigationController

        switch appTab {
        case .assets: viewController = walletNavWrapper
        case .trading: viewController = tradingCoordinator.navWrapper
        case .contacts: viewController = contactsNavWrapper
        case .settings: viewController = settingsCoordinator.navWrapper
        }

        if currentViewController != viewController {
            currentViewController = viewController

            viewController.popToRootViewController(animated: false)
            tabController.setViewController(viewController, animated: false, completion: nil)
        }
    }
}

extension ApplicationCoordinator: DelegateResponder {
    func didBecomeActive() {
        AddressResolver.fetchExchangeData()
        CacheManager.prefetchAssetImages()

        refreshAccount()
    }

    func willEnterForeground() {
        if SecurityOptionHelper.check(.pinOnLaunch) {
            if let presentedController = tabController.presentedViewController {
                presentedController.dismiss(animated: false, completion: nil)
            }

            delegate?.requestedAuthentication(self,
                                              container: tabController,
                                              options: AuthenticationCoordinator.defaultStartupOptions)
        }

        guard let account = core.accountService.account else { return }
        core.streamService.subscribeAll(account: account)
    }

    func didEnterBackground() {
        core.streamService.unsubscribeAll()
        authCompletion = nil
    }

    func refreshAccount() {
        core.updateService.update()
    }
}
