//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

protocol ApplicationCoordinatorDelegate: AnyObject {
    func switchToOnboarding()
}

final class ApplicationCoordinator {
    typealias PinEntryCompletion = () -> Void

    /// The controller class that directs which view controller is currently displayed
    let tabController = AppTabController(tab: .assets)
    
    // The coordinator responsible for the trading flow
    let tradingCoordinator = TradingCoordinator()
    
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

    /// The view controller used to display settings options
    lazy var settingsViewController: SettingsViewController = {
        let vc = SettingsViewController(options: EQSettings().options, customTitle: "MENU_OPTION_SETTINGS".localized())
        vc.delegate = self
        return vc
    }()
    
    /// The view controller used for receiving funds
    lazy var receiveViewController: ReceiveViewController = {
        return ReceiveViewController(address: "permanent receive address")
    }()

    /// The view controller used to switch which wallet is currently displayed, deallocated once finished using
    var walletSwitchingViewController: WalletSwitchingViewController?

    /// The view controller that allows users to send funds, deallocated once finished using
    var sendViewController: SendViewController?

    /// The view controller used to set the user's inflation pool, deallocated once finished using
    var inflationViewController: InflationViewController?

    /// Most tabbed view controllers need the top navbar - so we wrap every tab in an inner AppNavigationController
    var wrappingNavController: AppNavigationController?

    /// The completion handler to call when the pin view controller completes successfully
    var pinCompletion: PinEntryCompletion?

    var temporaryPinSetting: Bool!

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
            case .settings: vc = settingsViewController
        }

        let navWrapper = AppNavigationController(rootViewController: vc)
        wrappingNavController = navWrapper
        navWrapper.navigationBar.prefersLargeTitles = true
        
        setNavControllerHeader(type: appTab)

        tabController.setViewController(navWrapper, animated: false, completion: nil)
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
        case .node(_, let identifier, _, _) where identifier == "wallet-view-seed": displayPin() { self.displayMnemonic() }
        case .node(_, let identifier, _, _) where identifier == "wallet-clear": clearWallet()
        case .node(_, let identifier, _, _) where identifier.contains("security-pin"): managePin(identifier: identifier, newValue: value)
        case .section(_, let identifier, _) where identifier == "section-security": pushAdvancedPinControl(with: setting)
        default: print("Selected: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }

    func value(for setting: SettingNode) -> String {
        switch setting {
        case .node(_, let identifier, _, _) where identifier == "security-pin-enabled": return String(PinOptionHelper.pinSetting(for: .pinEnabled))
        case .node(_, let identifier, _, _) where identifier == "security-pin-launch": return String(PinOptionHelper.pinSetting(for: .pinOnLaunch))
        case .node(_, let identifier, _, _) where identifier == "security-pin-payments": return String(PinOptionHelper.pinSetting(for: .pinOnPayment))
        case .node(_, let identifier, _, _) where identifier == "security-pin-trading": return String(PinOptionHelper.pinSetting(for: .pinOnTrade))
        case .node(_, let identifier, _, _) where identifier == "security-pin-mnemonic": return String(PinOptionHelper.pinSetting(for: .pinOnMnemonic))
        default: return ""
        }
    }

    func managePin(identifier: String, newValue: String?) {
        guard let value = newValue else { return }

        if let value = Bool(value), let option = PinOptionHelper.PinOption(rawValue: identifier) {
            if option == .pinEnabled && !value {
                displayPin() { PinOptionHelper.set(option: option, value: value) }
            }

            PinOptionHelper.set(option: option, value: value)
        }
    }

    func pushAdvancedPinControl(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func clearWallet() {
        let alertController = UIAlertController(title: "Are you sure you want to clear this wallet?", message: nil, preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "Clear", style: .destructive, handler: { (action) -> Void in
            self.displayPin() {
                KeychainHelper.clearAll()
                PinOptionHelper.clear()
                self.delegate?.switchToOnboarding()
            }
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        wrappingNavController?.present(alertController, animated: true, completion: nil)
    }

    func displayPin(_ completion: PinEntryCompletion? = nil) {
        let pinViewController = PinViewController(mode: .dark,
                                                  pin: nil,
                                                  confirming: true,
                                                  isCloseDisplayed: true,
                                                  shouldSavePin: false)

        pinViewController.delegate = self
        pinCompletion = completion

        // Temporarily store the setting for if PIN entry is enabled
        temporaryPinSetting = PinOptionHelper.pinSetting(for: .pinEnabled)

        wrappingNavController?.present(pinViewController, animated: true)
    }

    func displayMnemonic() {
        let mnemonicViewController = MnemonicViewController(mnemonic: KeychainHelper.getMnemonic(), shouldSetPin: false, hideConfirmation: true)
        wrappingNavController?.pushViewController(mnemonicViewController, animated: true)
    }
}

extension ApplicationCoordinator: PinViewControllerDelegate {
    func pinEntryCancelled(_ vc: PinViewController) {
        vc.dismiss(animated: true, completion: nil)

        // We need to re-set the PIN enabled setting, in the case the user cancels input
        PinOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)

        settingsViewController.tableView.reloadData()
    }

    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool) {
        if KeychainHelper.checkPin(inPin: pin) {
            vc.dismiss(animated: true) {
                self.pinCompletion?()
                self.pinCompletion = nil
            }
        } else {
            vc.pinMismatchError()
        }
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
        walletSwitchVC.delegate = self

        walletSwitchVC.updateMenu(stellarAccount: account)

        tabController.present(container, animated: true, completion: nil)
    }
    
    func selectedReceive() {
        let address = walletViewController.accounts[0].accountId
        let receiveVC = ReceiveViewController(address: address)
        let container = AppNavigationController(rootViewController: receiveVC)
        
        receiveViewController = receiveVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        tabController.present(container, animated: true, completion: nil)
    }
}

extension ApplicationCoordinator: WalletSwitchingViewControllerDelegate {
    func didSelectSetInflation() {
        let inflationViewController = InflationViewController()
        self.inflationViewController = inflationViewController

        wrappingNavController?.pushViewController(inflationViewController, animated: true)
    }

    func didSelectAsset(index: Int) {
        walletViewController.selectAsset(at: index)
    }

    func reloadAssets() {
        walletViewController.getAccountDetails()
    }
}
