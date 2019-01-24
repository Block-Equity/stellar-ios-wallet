//
//  PaymentCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-21.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Whisper
import StellarHub

protocol PaymentCoordinatorDelegate: AnyObject {
    func dismiss(_ coordinator: PaymentCoordinator, container: UIViewController)
}

extension PaymentCoordinator {
    enum PaymentType {
        /// Displays the select asset screen, enter amount amount screen.
        case contact(LocalContact)

        /// Displays the prompty for address screen, enter amount screen.
        case wallet(StellarAsset)
    }
}

final class PaymentCoordinator {
    private let service: AccountManagementService
    private let account: StellarAccount
    private let type: PaymentType
    private var asset: StellarAsset?
    private var address: StellarAddress?

    /// The completion handler to call when the pin view controller completes successfully
    private var authCompletion: EmptyCompletion?

    /// The delegate to notify for payment events
    weak var delegate: PaymentCoordinatorDelegate?

    private lazy var navController: AppNavigationController = {
        var navController: AppNavigationController

        switch type {
        case .wallet(let selectedAsset):
            asset = selectedAsset
            addressViewController.update(with: account, asset: selectedAsset)
            navController = AppNavigationController(rootViewController: addressViewController)
        case .contact(let contact):
            address = StellarAddress(contact.address)
            navController = AppNavigationController(rootViewController: assetListViewController)
        }

        navController.navigationBar.prefersLargeTitles = true

        return navController
    }()

    private lazy var authenticationCoordinator: AuthenticationCoordinator = {
        let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: true,
                                                                   presentVC: true,
                                                                   forcedStyle: nil,
                                                                   limitPinEntries: true)

        let authCoordinator = AuthenticationCoordinator(container: navController, options: opts)
        authCoordinator.delegate = self

        return authCoordinator
    }()

    private lazy var assetListViewController: AssetListViewController = {
        let assetVC = AssetListViewController()
        _ = assetVC.view

        assetVC.addAssetView.isHidden = true
        assetVC.delegate = self
        assetVC.dataSource = assetListDataSource

        return assetVC
    }()

    private lazy var assetListDataSource: AssetListDataSource = {
        let dataSource = TradeAssetListDataSource(account: account,
                                                  assets: account.assets,
                                                  availableAssets: [],
                                                  selected: nil,
                                                  excluding: nil)
        dataSource.selectionDelegate = self
        dataSource.actionDelegate = self

        return dataSource
    }()

    private lazy var addressViewController: AddressEntryViewController = {
        let addressVC = AddressEntryViewController()
        _ = addressVC.view

        addressVC.delegate = self

        return addressVC
    }()

    private lazy var sendAmountViewController: SendAmountViewController = {
        let amountVC = SendAmountViewController()
        _ = amountVC.view

        amountVC.delegate = self

        return amountVC
    }()

    init?(accountService: AccountManagementService, account: StellarAccount, type: PaymentType) {
        self.service = accountService
        self.account = account
        self.type = type
    }

    func pay() -> UIViewController? {
        return navController
    }

    private func displayAuth(_ completion: EmptyCompletion? = nil) {
        authCompletion = completion
        authenticationCoordinator.authenticate()
    }

    private func sendPayment(address: StellarAddress, asset: StellarAsset, amount: Decimal, memo: String?) {
        showHud()
        let paymentData = StellarPaymentData(address: address, amount: amount, memo: memo, asset: asset)
        service.sendAmount(account: account, data: paymentData, delegate: self)
    }

    private func configureSend(with address: StellarAddress, asset: StellarAsset) {
        let sendBalance = account.availableSendBalance(for: asset)
        let viewModel = SendAmountViewController.ViewModel(destinationAddress: address.string,
                                                           exchange: AddressResolver.resolve(address: address),
                                                           availableSendBalance: sendBalance,
                                                           assetShortCode: asset.shortCode)

        sendAmountViewController.update(with: viewModel)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: navController.view, animated: true)
        hud.label.text = "SENDING_PAYMENT".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: navController.view, animated: true)
    }

    func displayTransactionSuccess() {
        hideHud()

        let message = Message(title: "TRANSACTION_SUCCESS".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navController, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navController)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.dismiss(self, container: self.navController)
            }
        }
    }
}

// MARK: - FrameworkErrorPresentable
extension PaymentCoordinator: FrameworkErrorPresentable {
    func displayFrameworkError(_ error: FrameworkError?, fallbackData: (title: String, message: String)) {
        display(error, viewController: navController, fallbackData: fallbackData)
    }
}

// MARK: - AddressEntryViewControllerDelegate
extension PaymentCoordinator: AddressEntryViewControllerDelegate {
    func completedAddressEntry(_ viewController: AddressEntryViewController, address: StellarAddress) {
        self.address = address
        guard let asset = self.asset else { return }

        self.configureSend(with: address, asset: asset)
        navController.pushViewController(sendAmountViewController, animated: true)
    }

    func cancelledAddressEntry(_ viewController: AddressEntryViewController) {
        navController.dismiss(animated: true, completion: nil)
    }

    func requestedScanQRCode(_ viewController: AddressEntryViewController) {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        navController.present(scanViewController, animated: true, completion: nil)
    }
}

// MARK: - AssetSelectionDelegate
extension PaymentCoordinator: AssetSelectionDelegate {
    func selected(_ asset: StellarAsset) {
        self.asset = asset
        guard let address = self.address else { return }

        self.configureSend(with: address, asset: asset)
        navController.pushViewController(sendAmountViewController, animated: true)
    }
}

// MARK: - SendAmountViewControllerDelegate
extension PaymentCoordinator: SendAmountViewControllerDelegate {
    func validateSendAmount(amount: String) -> Bool {
        guard let asset = asset else { return false }

        if let totalSendable = Decimal(string: amount) {
            return totalSendable.isZero ? false : totalSendable <= account.availableSendBalance(for: asset)
        }

        return false
    }

    func requestedSendAmount(_ viewController: SendAmountViewController, amount: Decimal, memo: String?) {
        guard let address = self.address, let asset = self.asset else { return }

        if SecurityOptionHelper.check(.pinOnPayment) {
            displayAuth {
                self.sendPayment(address: address, asset: asset, amount: amount, memo: memo)
            }
        } else {
            sendPayment(address: address, asset: asset, amount: amount, memo: memo)
        }
    }

    func cancelledSendAmount(_ viewController: SendAmountViewController) {
        delegate?.dismiss(self, container: navController)
    }
}

// MARK: - ScanViewControllerDelegate
extension PaymentCoordinator: ScanViewControllerDelegate {
    func setQR(_ viewController: ScanViewController, value: String) {
        address = StellarAddress(value)
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AssetListViewControllerDelegate
extension PaymentCoordinator: AssetListViewControllerDelegate {
    func requestedAddNewAsset(_ viewController: UIViewController) {
    }

    func requestedDismiss(_ viewController: UIViewController) {
        delegate?.dismiss(self, container: navController)
    }
}

// MARK: - AuthenticationCoordinatorDelegate
extension PaymentCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        authCompletion?()
        authCompletion = nil
    }

    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
        authCompletion = nil
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        authCompletion = nil
    }
}

// MARK: - SendAmountResponseDelegate
extension PaymentCoordinator: SendAmountResponseDelegate {
    func sentAmount(destination: StellarAddress) {
        displayTransactionSuccess()
    }

    func failed(error: FrameworkError) {
        hideHud()

        let fallbackTitle = "TRANSACTION_ERROR_TITLE".localized()
        let fallbackMessage = "TRANSACTION_ERROR_MESSAGE".localized()
        displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }
}

extension PaymentCoordinator: AssetActionDelegate {
    func requestedAdd(asset: StellarAsset) {
    }

    func requestedRemove(asset: StellarAsset) {
    }

    func requestedAction(_ actionIndex: Int, for asset: StellarAsset) {
    }
}
