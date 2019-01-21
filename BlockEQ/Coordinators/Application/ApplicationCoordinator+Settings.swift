//
//  ApplicationCoordinator+Settings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension ApplicationCoordinator: SettingsDelegate {
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
        case let network where network.contains("network-"):
            switchNetwork(with: setting)
        default:
            print("Selected Node: \(String(describing: setting.name)) \(setting.identifier)")
        }
    }

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
        case .node(_, let identifier, _, _) where identifier.contains("network-"):
            return UserDefaults.standard.string(forKey: "setting.network") ?? "Production"
        default: return ""
        }
    }

    func switchNetwork(with node: SettingNode) {
        UserDefaults.standard.set(node.name, forKey: "setting.network")
        UIAlertController.simpleAlert(title: "RESTART_REQUIRED".localized(),
                                      message: "CLEAR_WALLET_MESSAGE".localized(),
                                      presentingViewController: wrappingNavController!)
    }

    func manageWallet(with node: SettingNode) {
        if node.identifier == "keys-display-secret-seed" {
            displayAuth { self.displaySecretSeet() }
        } else if node.identifier == "keys-view-mnemonic" {
            displayAuth { self.displayMnemonic() }
        } else if node.identifier == "keys-export-private-key" {
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

    func pushSubsettings(with node: SettingNode) {
        let viewController = SettingsViewController(options: [node], customTitle: node.name)
        viewController.delegate = self
        wrappingNavController?.pushViewController(viewController, animated: true)
    }

    func pushWebViewController(with url: URL, title: String?) {
        let webController = WebViewController(url: url, pageTitle: title ?? "")
        self.wrappingNavController?.pushViewController(webController, animated: true)
    }

    func presentDiagnostics() {
        diagnosticCoordinator.reset()
        diagnosticCoordinator.runWalletDiagnostic()
        wrappingNavController?.present(diagnosticCoordinator.diagnosticViewController, animated: true, completion: nil)
    }

    func presentIndexingStatus() {
        let indexVC = IndexingViewController()
        indexVC.delegate = self

        indexingViewController = indexVC
        indexVC.update(with: nil, error: nil)

        wrappingNavController?.present(indexVC, animated: true)
    }

    func presentMimicAccount() {
        guard let viewController = self.wrappingNavController else { return }

        UIAlertController.prompt(title: "Account", message: "Enter Account ID to mimic", handler: { controller in
            #if DEBUG
            if let accountId = controller.textFields![0].text {
                KeychainHelper.save(accountId: accountId)
                self.core?.accountService.overrideWithAccount(id: accountId)
                self.core?.updateService.update()
            }
            #endif
        }, presentingViewController: viewController, placeholder: "Account ID")
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

    func clearWalletPrompt() {
        let alertController = UIAlertController(title: "CLEAR_WALLET_TITLE".localized(),
                                                message: nil,
                                                preferredStyle: .alert)

        let yesButton = UIAlertAction(title: "CLEAR_WALLET_ACTION".localized(),
                                      style: .destructive,
                                      handler: { (_) -> Void in
                                        self.clearWallet()
        })

        let cancelButton = UIAlertAction(title: "CANCEL_ACTION".localized(),
                                         style: .default,
                                         handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)

        wrappingNavController?.present(alertController, animated: true, completion: nil)
    }

    func clearWallet() {
        self.displayAuth {
            self.tradingCoordinator?.stopPeriodicOrderbookUpdates()

            KeychainHelper.clearAll()
            SecurityOptionHelper.clear()
            CacheManager.shared.clearAccountCache()

            self.delegate?.switchToOnboarding()

            self.switchedTabs(.assets)
            self.walletViewController.clear()

            self.core?.accountService.clear()
            self.core?.stopSubservices()
            self.core = nil
        }
    }

    func displayAuth(_ completion: EmptyCompletion? = nil) {
        // Temporarily store the toggled settings and trigger authentication to verify
        temporaryPinSetting = SecurityOptionHelper.optionSetting(for: .pinEnabled)
        temporaryBiometricSetting = SecurityOptionHelper.optionSetting(for: .useBiometrics)
        authCompletion = completion

        authenticationCoordinator.authenticate()
    }

    func displayMnemonic() {
        let mnemonic = core?.accountService.accountMnemonic()
        let phrase = core?.accountService.accountPassphrase()
        let mnemonicViewController = MnemonicViewController(mnemonic: mnemonic, passphrase: phrase, mode: .view)

        wrappingNavController?.pushViewController(mnemonicViewController, animated: true)
    }

    func displaySecretSeet() {
        var viewController: SecretSeedViewController

        if let seed = core?.accountService.accountSecretSeed() {
            viewController = SecretSeedViewController(seed)
        } else if let mnemonic = core?.accountService.accountMnemonic() {
            let passphrase = core?.accountService.accountPassphrase()
            viewController = SecretSeedViewController(mnemonic: mnemonic, passphrase: passphrase)
        } else {
            return
        }

        wrappingNavController?.pushViewController(viewController, animated: true)
    }
}
