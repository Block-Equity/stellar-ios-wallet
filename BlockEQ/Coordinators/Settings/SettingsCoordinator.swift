//
//  SettingsCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-02-04.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

protocol SettingsCoordinatorDelegate: AnyObject {
    func requestedAuthentication(_ coordinator: SettingsCoordinator,
                                 with options: AuthenticationCoordinator.AuthenticationOptions,
                                 authorized: EmptyCompletion?)
    func clearedWallet()
}

final class SettingsCoordinator {
    let core: CoreService

    lazy var navWrapper: AppNavigationController = {
        return AppNavigationController(rootViewController: settingsViewController)
    }()

    // The coordinator responsible for managing application diagnostics
    let diagnosticCoordinator = DiagnosticCoordinator()

    /// The view controller used to display settings options
    lazy var settingsViewController: SettingsViewController = {
        let viewController = SettingsViewController(options: EQSettings.options,
                                                    customTitle: "MENU_OPTION_SETTINGS".localized())
        viewController.delegate = self
        return viewController
    }()

    /// The view controller used to help fill the address field more quickly
    var mergeViewController: MergeAccountViewController?

    //The view controller responsible for adding and editing Stellar Contacts
    var indexingViewController: IndexingViewController?

    var temporaryPinSetting: Bool!
    var temporaryBiometricSetting: Bool!

    weak var delegate: SettingsCoordinatorDelegate?

    init(core: CoreService) {
        self.core = core

        core.indexingService.delegate = self
    }

    func storeTemporaryPINSettings() {
        // Temporarily store the toggled settings and trigger authentication to verify
        temporaryPinSetting = SecurityOptionHelper.optionSetting(for: .pinEnabled)
        temporaryBiometricSetting = SecurityOptionHelper.optionSetting(for: .useBiometrics)
    }

    func restoreTemporaryPINSettings() {
        // We need to re-set the previously switched setting, in the case the user cancels the authentication challenge
        SecurityOptionHelper.set(option: .pinEnabled, value: temporaryPinSetting)
        SecurityOptionHelper.set(option: .useBiometrics, value: temporaryBiometricSetting)

        settingsViewController.tableView?.reloadData()
    }

    //swiftlint:disable cyclomatic_complexity
    func processNode(with identifier: String, setting: SettingNode) {
        switch identifier {
        case "wallet-clear":
            clearWalletPrompt()
        case let keys where keys.contains("keys-"):
            manageWallet(with: setting)
        case "about-application":
            displayApplicationInfo()
        case "about-terms":
            pushWebViewController(with: BlockEQURL.termsAndConditions.url, title: "SETTINGS_OPTION_TERMS".localized())
        case "about-privacy":
            pushWebViewController(with: BlockEQURL.privacyPolicy.url, title: "SETTINGS_OPTION_PRIVACY".localized())
        case  "support-start-diagnostic":
            presentDiagnostics()
        case  "debug-check-indexing":
            presentIndexingStatus()
        case "debug-mimic-account":
            presentMimicAccount()
        case "debug-fund-testnet-acc":
            fundTestnetAccount()
        case let network where network.contains("network-"):
            switchNetwork(with: setting)
        case "wallet-merge":
            pushMergeViewController()
        default:
            print("Selected Node: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }
    //swiftlint:enable cyclomatic_complexity

    func processSection(with identifier: String, setting: SettingNode) {
        switch identifier {
        case "section-security":
            pushSubsettings(with: setting)
        case "section-keys":
            pushSubsettings(with: setting)
        case "section-network":
            pushSubsettings(with: setting)
        default:
            print("Selected Section: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }

    func switchNetwork(with node: SettingNode) {
        UserDefaults.standard.set(node.name, forKey: "setting.network")
        UIAlertController.simpleAlert(title: "RESTART_REQUIRED".localized(),
                                      message: "CLEAR_WALLET_MESSAGE".localized(),
                                      presentingViewController: navWrapper)
    }

    func manageSecurity(identifier: String, newValue: String?) {
        guard let value = newValue else { return }

        if let value = Bool(value), let option = SecurityOptionHelper.SecurityOption(rawValue: identifier) {
            if !value {
                delegate?.requestedAuthentication(self, with: AuthenticationCoordinator.defaultConfirmationOptions,
                                                  authorized: {
                    SecurityOptionHelper.set(option: option, value: value)
                })
            }

            SecurityOptionHelper.set(option: option, value: value)
        }
    }

    func pushSubsettings(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        navWrapper.pushViewController(viewController, animated: true)
    }

    func pushWebViewController(with url: URL, title: String?) {
        let webController = WebViewController(url: url, pageTitle: title ?? "")
        self.navWrapper.pushViewController(webController, animated: true)
    }

    func pushMergeViewController() {
        guard let account = core.accountService.account else {
            return
        }

        let mergeVC = MergeAccountViewController()
        mergeVC.delegate = self
        mergeVC.update(with: account.address, destinationAddress: nil)

        mergeViewController = mergeVC

        self.navWrapper.pushViewController(mergeVC, animated: true)
    }

    func presentDiagnostics() {
        diagnosticCoordinator.reset()
        diagnosticCoordinator.runWalletDiagnostic()
        navWrapper.present(diagnosticCoordinator.diagnosticViewController, animated: true, completion: nil)
    }

    func presentMimicAccount() {
        UIAlertController.prompt(title: "Account", message: "Enter Account ID to mimic", handler: { controller in
            #if DEBUG
            if let accountId = controller.textFields![0].text {
                KeychainHelper.save(accountId: accountId)
                self.core.accountService.overrideWithAccount(id: accountId)
                self.core.updateService.update()
            }
            #endif
        }, presentingViewController: navWrapper, placeholder: "Account ID")
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

        self.navWrapper.present(controller, animated: true, completion: nil)
    }
}

extension SettingsCoordinator: SettingsDelegate {
    func selected(setting: SettingNode, value: String?) {
        switch setting {
        case .node(_, let identifier, _, _) where identifier.contains("security-"):
            manageSecurity(identifier: identifier, newValue: value)
        case .node(_, let identifier, _, _):
            processNode(with: identifier, setting: setting)
        case .section(_, let identifier, _):
            processSection(with: identifier, setting: setting)
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
            return String(SecurityOptionHelper.optionSetting(for: .pinOnWallet))
        case .node(_, let identifier, _, _) where identifier.contains("network-"):
            return UserDefaults.standard.string(forKey: "setting.network") ?? "Production"
        default: return ""
        }
    }
}

extension SettingsCoordinator: MergeAccountViewControllerDelegate {
    func requestedMergeAccount(_ viewController: MergeAccountViewController, destination: StellarAddress) {
        delegate?.requestedAuthentication(self, with: AuthenticationCoordinator.defaultConfirmationOptions,
                                          authorized: {
            self.mergeViewController?.showHud()
            self.core.accountService?.mergeAccount(with: destination, delegate: self)
        })
    }

    func requestedQRScanner(_ viewController: MergeAccountViewController) {
        let scanVC = ScanViewController()
        scanVC.delegate = self

        navWrapper.pushViewController(scanVC, animated: true)
    }
}

extension SettingsCoordinator: MergeAccountResponseDelegate {
    func merged(account source: StellarAccount, into destination: StellarAddress) {
        mergeViewController?.hideHud()

        let hud = MBProgressHUD.showAdded(to: navWrapper.view, animated: true)
        hud.label.text = "ACCOUNT_MERGED".localized()
        hud.animationType = .zoom
        hud.mode = .text
        hud.hide(animated: true, afterDelay: 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.delegate?.clearedWallet()
        }
    }

    func mergeFailed(with error: FrameworkError) {
        mergeViewController?.hideHud()
        mergeViewController?.displayFrameworkError(error, fallbackData: (title: "UNKNOWN_ERROR_TITLE".localized(),
                                                                         message: "UNKNOWN_ERROR_MESSAGE".localized()))
    }
}

extension SettingsCoordinator: ScanViewControllerDelegate {
    func dismiss(_ viewController: ScanViewController) {
    }

    func setQR(_ viewController: ScanViewController, value: String) {
        guard let account = core.accountService.account, let destination = StellarAddress(value) else { return }
        mergeViewController?.update(with: account.address, destinationAddress: destination)

        navWrapper.popViewController(animated: true)
    }
}
