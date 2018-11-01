//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService
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
    var core: StellarCoreService? {
        didSet {
            guard let coreService = core,
                let accountId = KeychainHelper.accountId,
                let address = StellarAddress(accountId) else {
                    return
            }

            coreService.accountService.registerForUpdates(self)
            coreService.indexingService.delegate = self

            migrateIfEligible(using: coreService.accountService)
            try? coreService.accountService.restore(with: address)
            coreService.accountService.startPeriodicUpdates()
            coreService.accountService.update()

            tradingCoordinator.tradeService = coreService.tradeService
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
    }

    func migrateIfEligible(using service: StellarAccountService) {
        if KeychainHelper.canMigrateToNewFormat,
            let accountId = KeychainHelper.accountId,
            let address = StellarAddress(accountId) {
            try? service.migrateAccount(with: address,
                                        mnemonicKey: KeychainHelper.mnemonicKey,
                                        seedKey: KeychainHelper.secretSeedKey,
                                        pubKey: KeychainHelper.publicSeedKey,
                                        privKey: KeychainHelper.privateSeedKey)

            KeychainHelper.clearStellarSecrets()
        }
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

extension ApplicationCoordinator: SettingsDelegate {
    func selected(setting: SettingNode, value: String?) {
        switch setting {
        case .node(_, let identifier, _, _) where identifier == "wallet-clear":
            clearWallet()
        case .node(_, let identifier, _, _) where identifier.contains("security-"):
            manageSecurity(identifier: identifier, newValue: value)
        case .node(name: _, let identifier, _, _) where identifier.contains("keys-"):
            manageWallet(with: setting)
        case .node(_, let identifier, _, _) where identifier == "about-application":
            displayApplicationInfo()
        case .node(_, let identifier, _, _) where identifier == "about-terms":
            pushWebViewController(with: BlockEQURL.termsAndConditions.url, title: "SETTINGS_OPTION_TERMS".localized())
        case .node(_, let identifier, _, _) where identifier == "about-privacy":
            pushWebViewController(with: BlockEQURL.privacyPolicy.url, title: "SETTINGS_OPTION_PRIVACY".localized())
        case .section(_, let identifier, _) where identifier == "section-security":
            pushAdvancedPinControl(with: setting)
        case .section(_, let identifier, _) where identifier == "section-keys":
            pushKeyManagement(with: setting)
        default: print("Selected: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }

    func value(for setting: SettingNode) -> String {
        switch setting {
        case .node(_, let identifier, _, _) where identifier == "security-use-biometrics":
            let available = SecurityOptionHelper.optionSetting(for: .useBiometrics) &&
                AuthenticationCoordinator.biometricsAvailable
            return String(available)
        case .node(_, let identifier, _, _) where identifier == "security-pin-enabled":
            return String(SecurityOptionHelper.optionSetting(for: .pinEnabled))
        case .node(_, let identifier, _, _) where identifier == "security-pin-launch":
            return String(SecurityOptionHelper.optionSetting(for: .pinOnLaunch))
        case .node(_, let identifier, _, _) where identifier == "security-pin-payments":
            return String(SecurityOptionHelper.optionSetting(for: .pinOnPayment))
        case .node(_, let identifier, _, _) where identifier == "security-pin-trading":
            return String(SecurityOptionHelper.optionSetting(for: .pinOnTrade))
        case .node(_, let identifier, _, _) where identifier == "security-pin-mnemonic":
            return String(SecurityOptionHelper.optionSetting(for: .pinOnMnemonic))
        default: return ""
        }
    }

    func manageWallet(with node: SettingNode) {
        if node.identifier == "keys-display-secret-seed" {
            displayAuth { self.displaySecretSeet() }
        } else if node.identifier == "keys-export-private-key" {

        } else if node.identifier == "keys-view-mnemonic" {
            displayAuth { self.displayMnemonic() }
        }
    }

    func manageSecurity(identifier: String, newValue: String?) {
        guard let value = newValue else { return }

        if let value = Bool(value), let option = SecurityOptionHelper.SecurityOption(rawValue: identifier) {
            if !value {
                displayAuth { SecurityOptionHelper.set(option: option, value: value) }
            }

            SecurityOptionHelper.set(option: option, value: value)
        }
    }

    func pushKeyManagement(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func pushAdvancedPinControl(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func pushWebViewController(with url: URL, title: String?) {
        let webController = WebViewController(url: url, pageTitle: title ?? "")
        self.wrappingNavController?.pushViewController(webController, animated: true)
    }

    func displayApplicationInfo() {
        let informationString = DeviceString.application.value
        let controller = UIAlertController(title: "SETTINGS_OPTION_APPLICATION".localized(),
                                           message: informationString,
                                           preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil)
        let copyAction = UIAlertAction(title: "COPY".localized(), style: .default) { _ in
            UIPasteboard.general.string = informationString
        }

        controller.addAction(copyAction)
        controller.addAction(dismissAction)

        self.wrappingNavController?.present(controller, animated: true, completion: nil)
    }

    func clearWallet() {
        let alertController = UIAlertController(title: "CLEAR_WALLET_TITLE".localized(),
                                                message: nil,
                                                preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "CLEAR_WALLET_ACTION".localized(),
                                      style: .destructive,
                                      handler: { (_) -> Void in
            self.displayAuth {
                KeychainHelper.clearAll()
                SecurityOptionHelper.clear()
                self.core?.accountService.clear()
                self.core = nil
                self.delegate?.switchToOnboarding()
            }
        })

        let cancelButton = UIAlertAction(title: "CANCEL_ACTION".localized(),
                                         style: .default,
                                         handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        wrappingNavController?.present(alertController, animated: true, completion: nil)
    }

    func displayAuth(_ completion: PinEntryCompletion? = nil) {
        // Temporarily store the toggled settings and trigger authentication to verify
        temporaryPinSetting = SecurityOptionHelper.optionSetting(for: .pinEnabled)
        temporaryBiometricSetting = SecurityOptionHelper.optionSetting(for: .useBiometrics)
        authCompletion = completion

        authenticate()
    }

    func displayMnemonic() {
        let mnemonic = core?.accountService.accountMnemonic()
        let mnemonicViewController = MnemonicViewController(mnemonic: mnemonic,
                                                            shouldSetPin: false,
                                                            hideConfirmation: true)

        wrappingNavController?.pushViewController(mnemonicViewController, animated: true)
    }

    func displaySecretSeet() {
        var viewController: SecretSeedViewController

        if let seed = core?.accountService.accountSecretSeed() {
            viewController = SecretSeedViewController(seed)
        } else if let mnemonic = core?.accountService.accountMnemonic() {
            viewController = SecretSeedViewController(mnemonic: mnemonic)
        } else {
            return
        }

        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func authenticate(_ style: AuthenticationCoordinator.AuthenticationStyle? = nil) {
        let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: true,
                                                                   presentVC: true,
                                                                   forcedStyle: style,
                                                                   limitPinEntries: true)
        let authCoordinator = AuthenticationCoordinator(container: self.tabController, options: opts)
        authCoordinator.delegate = self
        authenticationCoordinator = authCoordinator

        authCoordinator.authenticate()
    }
}

extension ApplicationCoordinator: StellarIndexingServiceDelegate {
    func finishedIndexing(_ service: StellarIndexingService) {
        print("Indexing finished!")
    }

    func updatedProgress(_ service: StellarIndexingService, progress: Progress) {
        print("Indexing progress: \(progress.fractionCompleted)")
    }
}
