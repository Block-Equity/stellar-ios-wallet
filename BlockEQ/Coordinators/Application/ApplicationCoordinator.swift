//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import WebKit
import os.log

protocol ApplicationCoordinatorDelegate: AnyObject {
    func switchToOnboarding()
}

final class ApplicationCoordinator {
    typealias PinEntryCompletion = () -> Void

    /// The controller class that directs which view controller is currently displayed
    let tabController = AppTabController(tab: .assets)

    /// The current visible view controller
    var currentViewController = UIViewController()

    // The coordinator responsible for the trading flow
    let tradingCoordinator = TradingCoordinator()

    // The coordinator responsible for the peer to peer flow
    let p2pCoordinator = P2PCoordinator()

    let diagnosticCoordinator = DiagnosticCoordinator()

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
    var walletViewController: WalletViewController

    //The view controller responsible for displaying contacts
    lazy var contactsViewController: ContactsViewController = {
        let contactsVC = ContactsViewController(service: core!.accountService)
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

    /// The service object that manages the current stellar account
    var core: CoreService? {
        didSet {
            guard let coreService = core,
                let accountId = KeychainHelper.accountId,
                let address = StellarAddress(accountId) else {
                    return
            }

            coreService.accountService.registerForUpdates(self)
            coreService.updateService.registerForUpdates(self)
            coreService.indexingService.delegate = self
            coreService.streamService.delegate = self

            migrateIfEligible(using: coreService.accountService)
            try? coreService.accountService.restore(with: address)
            coreService.updateService.startPeriodicUpdates()
            coreService.updateService.update()

            tradingCoordinator.tradeService = coreService.tradeService
            tradingCoordinator.updateService = coreService.updateService
            tradingCoordinator.accountService = coreService.accountService
        }
    }

    /// The view controller used to switch which wallet is currently displayed, deallocated once finished using
    var walletSwitchingViewController: WalletSwitchingViewController?

    /// The view controller that allows users to send funds, deallocated once finished using
    var sendViewController: SendViewController?

    /// The view controller used to set the user's inflation pool, deallocated once finished using
    var inflationViewController: InflationViewController?

    /// The view controller used to set to add an asset, deallocated once finished using
    var addAssetViewController: AddAssetViewController?

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
    var authCompletion: PinEntryCompletion?

    var authenticationCoordinator: AuthenticationCoordinator?

    var temporaryPinSetting: Bool!
    var temporaryBiometricSetting: Bool!

    weak var delegate: ApplicationCoordinatorDelegate?

    init() {
        let walletVC = WalletViewController()
        self.walletViewController = walletVC
        walletVC.delegate = self

        tabController.tabDelegate = self
        tradingCoordinator.delegate = self

        AddressResolver.fetchExchangeData()
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

    func didBecomeActive() {
        refreshAccount()
    }

    func willEnterForeground() {
        guard let account = core?.accountService.account else { return }
        core?.streamService.subscribeAll(account: account)
    }

    func didEnterBackground() {
        core?.streamService.unsubscribeAll()
    }

    func refreshAccount() {
        core?.updateService.update()
    }
}

extension ApplicationCoordinator: TradeHeaderViewDelegate {
    func switchedSegment(_ type: TradeSegment) {
        tradingCoordinator.switchedSegment(type)
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
        case .p2p: viewController = p2pCoordinator.p2pViewController
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
