//
//  ApplicationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

final class ApplicationCoordinator {
    /// The controller class that directs which view controller is currently displayed
    let tabController = AppTabController(tab: .assets)

    /// The view controller used to list out the user's assets
    lazy var walletViewController: WalletViewController = {
        let vc = WalletViewController()
        vc.delegate = self
        return vc
    }()

    /// The view controller used for trading
    lazy var tradeContainerViewController: UIViewController = { return TradingCoordinator().segmentController }()

    /// The view controller used to display settings options
    lazy var settingsViewConroller: SettingsViewController = {
        let vc = SettingsViewController(options: EQSettings().options)
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

    init() {
        tabController.tabDelegate = self
    }
}

extension ApplicationCoordinator: AppTabControllerDelegate {
    func switchedTabs(_ appTab: ApplicationTab) {
        var vc: UIViewController

        switch appTab {
            case .assets: vc = walletViewController
            case .trading: vc = tradeContainerViewController
            case .receive:
                // TODO: Accounts shouldn't live just on the wallet VC, need to refactor this eventually
                var address = "default address"
                if walletViewController.pageControl != nil {
                    let index = walletViewController.pageControl.currentPage
                    address = walletViewController.accounts[index].accountId
                }

                receiveViewController.address = address
                vc = receiveViewController
            case .settings: vc = settingsViewConroller
        }

        let navWrapper = AppNavigationController(rootViewController: vc)
        wrappingNavController = navWrapper

        tabController.setViewController(navWrapper, animated: false, completion: nil)
    }
}

extension ApplicationCoordinator: SettingsDelegate {
    func selected(setting: SettingNode) {
        switch setting {
        case .node(_, let identifier, _) where identifier == "wallet-view-seed": displayPin(isShowingSeed: true)
        case .node(_, let identifier, _) where identifier == "wallet-clear": clearWallet()
        case .node(_, let identifier, _) where identifier == "debug-disable-pin": disablePinCheck()
        default: print("Selected: \(String(describing: setting.name))")
        }
    }

    func clearWallet() {
        let alertController = UIAlertController(title: "Are you sure you want to clear this wallet?", message: nil, preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "Clear", style: .destructive, handler: { (action) -> Void in
            self.displayPin(isShowingSeed: false)
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        wrappingNavController?.present(alertController, animated: true, completion: nil)
    }

    func displayPin(isShowingSeed: Bool) {
        let pinViewController = PinViewController(pin: nil,
                                                  confirming: true,
                                                  isCloseDisplayed: false,
                                                  shouldSavePin: false)

        pinViewController.delegate = self

        wrappingNavController?.pushViewController(pinViewController, animated: true)
    }

    func disablePinCheck() {
        KeychainHelper.setPinWhenEnteringApp(shouldSet: false)
    }
}

extension ApplicationCoordinator: PinViewControllerDelegate {
    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool) {
        if KeychainHelper.checkPin(inPin: pin) {
            let mnemonicViewController = MnemonicViewController(mnemonic: KeychainHelper.getMnemonic(), shouldSetPin: false, hideConfirmation: true)
            wrappingNavController?.popViewController(animated: false)
            wrappingNavController?.pushViewController(mnemonicViewController, animated: true)
        } else {
            vc.displayPinMismatchError()
        }
    }
}

extension ApplicationCoordinator: WalletViewControllerDelegate {
    func selectedSend(_ vc: WalletViewController, account: StellarAccount, index: Int) {
        let sendVC = SendViewController(stellarAccount: account, currentAssetIndex: index)
        let container = AppNavigationController(rootViewController: sendVC)

        sendViewController = sendVC
        wrappingNavController = container

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
