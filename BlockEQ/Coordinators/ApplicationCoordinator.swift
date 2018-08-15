//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation
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
        let view = TradeHeaderView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: 44.0)))
        view.tradeHeaderViewDelegate = self
        return view
    }()

    /// The view controller used to list out the user's assets
    lazy var walletViewController: WalletViewController = {
        let vc = WalletViewController()
        vc.delegate = self
        return vc
    }()
    
    //The view controller responsible for displaying contacts
    lazy var contactsViewController: ContactsViewController = {
        let vc = ContactsViewController()
        vc.delegate = self
        return vc
    }()

    /// The view controller used to display settings options
    lazy var settingsViewController: SettingsViewController = {
        let vc = SettingsViewController(options: EQSettings().options, customTitle: "MENU_OPTION_SETTINGS".localized())
        vc.delegate = self
        return vc
    }()

    /// The view controller used for receiving funds
    lazy var receiveViewController: ReceiveViewController = {
        return ReceiveViewController(address: "permanent receive address", isPersonalToken: false)
    }()

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
        tabController.tabDelegate = self
        tradingCoordinator.delegate = self
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
        var vc: UIViewController

        switch appTab {
            case .assets: vc = walletViewController
            case .trading: vc = tradingCoordinator.segmentController
            case .contacts: vc = contactsViewController
            case .settings: vc = settingsViewController
            case .p2p: vc = p2pCoordinator.p2pViewController
        }

        if currentViewController != vc {
            currentViewController = vc

            let navWrapper = AppNavigationController(rootViewController: vc)
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
        case .node(_, let identifier, _, _) where identifier == "wallet-view-seed":
            displayAuth { self.displayMnemonic() }
        case .node(_, let identifier, _, _) where identifier == "wallet-clear":
            clearWallet()
        case .node(_, let identifier, _, _) where identifier.contains("security-"):
            manageSecurity(identifier: identifier, newValue: value)
        case .section(_, let identifier, _) where identifier == "section-security":
            pushAdvancedPinControl(with: setting)
        default: print("Selected: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }

    func value(for setting: SettingNode) -> String {
        switch setting {
        case .node(_, let identifier, _, _) where identifier == "security-use-biometrics":
            let available = SecurityOptionHelper.optionSetting(for: .useBiometrics) &&
                AuthenticationCoordinator.biometricsAvailable()
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

    func manageSecurity(identifier: String, newValue: String?) {
        guard let value = newValue else { return }

        if let value = Bool(value), let option = SecurityOptionHelper.SecurityOption(rawValue: identifier) {
            if !value {
                displayAuth { SecurityOptionHelper.set(option: option, value: value) }
            }

            SecurityOptionHelper.set(option: option, value: value)
        }
    }

    func pushAdvancedPinControl(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func clearWallet() {
        let alertController = UIAlertController(title: "Are you sure you want to clear this wallet?", message: nil, preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "Clear", style: .destructive, handler: { (_) -> Void in
            self.displayAuth {
                KeychainHelper.clearAll()
                SecurityOptionHelper.clear()
                self.delegate?.switchToOnboarding()
            }
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)

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
        let mnemonicViewController = MnemonicViewController(mnemonic: KeychainHelper.getMnemonic(), shouldSetPin: false, hideConfirmation: true)
        wrappingNavController?.pushViewController(mnemonicViewController, animated: true)
    }

    func authenticate(_ style: AuthenticationCoordinator.AuthenticationStyle? = nil) {
        let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: true, presentVC: true, forcedStyle: style)
        let authCoordinator = AuthenticationCoordinator(container: self.tabController, options: opts)
        authCoordinator.delegate = self
        authenticationCoordinator = authCoordinator

        authCoordinator.authenticate()
    }
}

extension ApplicationCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
        // We need to re-set the previously switched setting, in the case the user cancels the authentication challenge
        SecurityOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)
        SecurityOptionHelper.set(option: .useBiometrics, value: temporaryBiometricSetting)

        settingsViewController.tableView.reloadData()
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        // We need to re-set the previously switched setting, in the case the user cancels the authentication challenge
        SecurityOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)
        SecurityOptionHelper.set(option: .useBiometrics, value: temporaryBiometricSetting)

        settingsViewController.tableView.reloadData()
    }

    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        authenticationCoordinator = nil

        authCompletion?()
        authCompletion = nil
    }
}

extension ApplicationCoordinator: WalletViewControllerDelegate {
    func selectedSend(_ vc: WalletViewController, account: StellarAccount, index: Int) {
        let sendVC = SendViewController(stellarAccount: account, currentAssetIndex: index)
        let container = AppNavigationController(rootViewController: sendVC)

        sendViewController = sendVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedWalletSwitch(_ vc: WalletViewController, account: StellarAccount) {
        let walletSwitchVC = WalletSwitchingViewController()
        let container = AppNavigationController(rootViewController: walletSwitchVC)

        walletSwitchingViewController = walletSwitchVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        walletSwitchVC.delegate = self

        walletSwitchVC.updateMenu(stellarAccount: account)

        tabController.present(container, animated: true, completion: nil)
    }

    func selectedReceive() {
        let address = walletViewController.accounts[0].accountId
        let receiveVC = ReceiveViewController(address: address, isPersonalToken: false)
        let container = AppNavigationController(rootViewController: receiveVC)

        receiveViewController = receiveVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true

        tabController.present(container, animated: true, completion: nil)
    }

    func selectBalance(account: StellarAccount, index: Int) {
        let balanceVC = BalanceViewController(stellarAccount: account, stellarAsset: account.assets[index])
        let container = AppNavigationController(rootViewController: balanceVC)

        balanceViewController = balanceVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true

        tabController.present(container, animated: true, completion: nil)
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
    func selectedAddToAddressBook(identifier: String, name: String) {
        let stellarContactVC = StellarContactViewController(identifier: identifier, name: name)
        let container = AppNavigationController(rootViewController: stellarContactVC)
        
        stellarContactViewController = stellarContactVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        tabController.present(container, animated: true, completion: nil)
    }
}
