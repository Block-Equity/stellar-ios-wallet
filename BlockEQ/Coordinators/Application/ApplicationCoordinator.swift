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

    // The coordinator responsible for managing application diagnostics
    let diagnosticCoordinator = DiagnosticCoordinator()

    // A safety object to throttle how many requests to update data we make when receiving stream objects
    lazy var streamUpdateThrottler: Throttler = {
        return Throttler(time: .seconds(5), { [unowned self] in
            self.core.updateService.update()
        })
    }()

    /// The service object that manages interactions with the Stellar network
    var core: CoreService

    // The coordinator responsible for the trading flow
    lazy var tradingCoordinator: TradingCoordinator = {
        let tradingCoordinator = TradingCoordinator(core: core)
        tradingCoordinator.delegate = self

        return tradingCoordinator
    }()

    /// The view that handles all switching in the header
    lazy var tradeHeaderView: TradeHeaderView = {
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: 44.0))
        let view = TradeHeaderView(frame: rect)
        view.tradeHeaderViewDelegate = self
        return view
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

    /// The view controller used to display settings options
    var settingsViewController: SettingsViewController {
        let viewController = SettingsViewController(options: EQSettings.options,
                                                    customTitle: "MENU_OPTION_SETTINGS".localized())
        viewController.delegate = self
        return viewController
    }

    /// The view controller used to display the minimum balance, deallocated once finished using
    var balanceViewController: BalanceViewController?

    /// The view controller used to display transaction details, deallocated once finished using
    var transactionViewController: TransactionDetailsViewController?

    /// Most tabbed view controllers need the top navbar - so we wrap every tab in an inner AppNavigationController
    var wrappingNavController: AppNavigationController?

    //The view controller responsible for adding and editing Stellar Contacts
    var stellarContactViewController: StellarContactViewController?

    //The view controller responsible for adding and editing Stellar Contacts
    var indexingViewController: IndexingViewController?

    /// The completion handler to call when the pin view controller completes successfully
    var authCompletion: EmptyCompletion?

    var temporaryPinSetting: Bool!
    var temporaryBiometricSetting: Bool!

    weak var delegate: ApplicationCoordinatorDelegate?

    init(with coreService: CoreService) {
        core = coreService

        guard let accountId = KeychainHelper.accountId, let address = StellarAddress(accountId) else {
            return
        }

        core.accountService.registerForUpdates(self)
        core.updateService.registerForUpdates(self)
        core.indexingService.delegate = self
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
}

extension ApplicationCoordinator: TradeHeaderViewDelegate {
    func switchedSegment(_ type: TradeSegment) -> Bool {
        return tradingCoordinator.switchedSegment(type)
    }
}

extension ApplicationCoordinator: TradingCoordinatorDelegate {
    func setScroll(offset: CGFloat, page: Int) {
        tradeHeaderView.sliderOriginConstraint.constant = offset
        tradeHeaderView.setTitleSelected(index: page)
    }
}

extension ApplicationCoordinator: AppTabControllerDelegate {
    func switchedTabs(_ appTab: ApplicationTab) {
        var viewController: UIViewController

        switch appTab {
        case .assets: viewController = walletViewController
        case .trading: viewController = tradingCoordinator.segmentController
        case .contacts: viewController = contactsViewController
        case .settings: viewController = settingsViewController
        }

        if currentViewController != viewController {
            currentViewController = viewController

            let navWrapper = AppNavigationController(rootViewController: viewController)
            wrappingNavController = navWrapper

            if appTab != .trading {
                navWrapper.navigationBar.prefersLargeTitles = true
            }

            setNavControllerHeader(type: appTab)

            tabController.setViewController(navWrapper, animated: false, completion: nil)
        }
    }

    func setNavControllerHeader(type: ApplicationTab) {
        if type == .trading {
            wrappingNavController?.navigationBar.addSubview(tradeHeaderView)
        }
    }
}

extension ApplicationCoordinator: IndexingServiceDelegate {
    func finishedIndexing(_ service: IndexingService) {
        print("Indexing finished!")
        indexingViewController?.update(with: 1, error: nil)
        transactionViewController?.requestData()
    }

    func errorIndexing(_ service: IndexingService, error: Error?) {
        if let error = error {
            print("Indexing Error:", error.localizedDescription)
            indexingViewController?.update(with: nil, error: error)
        } else {
            print("Indexing Error with no reason specified.")
        }
    }

    func updatedProgress(_ service: IndexingService, completed: Double) {
        indexingViewController?.update(with: completed, error: nil)
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
