//
//  AssetCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-01.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub
import Whisper

protocol AssetCoordinatorDelegate: AnyObject {
    func selected(asset: StellarAsset)
    func added(asset: StellarAsset, account: StellarAccount)
    func removed(asset: StellarAsset, account: StellarAccount)
    func dismissed(coordinator: AssetCoordinator, viewController: UIViewController)
    func dataSource() -> AssetListDataSource?
}

protocol AssetActionDelegate: AnyObject {
    func requestedAdd(asset: StellarAsset)
    func requestedRemove(asset: StellarAsset)
    func requestedAction(_ actionIndex: Int, for asset: StellarAsset)
}

protocol AssetSelectionDelegate: AnyObject {
    func selected(_ asset: StellarAsset)
}

final class AssetCoordinator {
    private let accountService: AccountManagementService
    private var account: StellarAccount
    private var addEnabled: Bool

    private lazy var navController: AppNavigationController = {
        let navController = AppNavigationController(rootViewController: assetListViewController)
        navController.navigationBar.prefersLargeTitles = true

        return navController
    }()

    private lazy var addAssetViewController: AddAssetViewController = {
        let addVC = AddAssetViewController()
        addVC.delegate = self

        return addVC
    }()

    private lazy var assetListViewController: AssetListViewController = {
        let assetVC = AssetListViewController()
        assetVC.delegate = self

        // Force the view hierarchy to load in order to set the collection view's outlets
        _ = assetVC.view

        if !addEnabled {
            assetVC.hideAddAsset()
        }

        return assetVC
    }()

    /// The view controller used to set the user's inflation pool, deallocated once finished using
    private lazy var inflationViewController: InflationViewController = {
        let inflationVC = InflationViewController(account: self.account)
        inflationVC.delegate = self

        return inflationVC
    }()

    private var assetListDataSource: AssetListDataSource? {
        didSet {
            assetListDataSource?.actionDelegate = self
            assetListDataSource?.selectionDelegate = self
            assetListViewController.dataSource = assetListDataSource
        }
    }

    weak var delegate: AssetCoordinatorDelegate?

    init(accountService: AccountManagementService, account: StellarAccount, addEnabled: Bool = true) {
        self.account = account
        self.accountService = accountService
        self.addEnabled = addEnabled
    }

    func dismiss() {
        navController.dismiss(animated: true) {
            self.delegate?.dismissed(coordinator: self, viewController: self.navController)
        }
    }

    func add(_ asset: StellarAsset, to account: StellarAccount) {
        guard account.hasRequiredNativeBalanceForNewEntry else {
            let minimumBalance = account.newEntryMinBalance.displayFormattedString
            assetListViewController.displayLowBalanceError(minimum: minimumBalance)
            return
        }

        showHud(message: "ADDING_ASSET".localized())
        accountService.changeTrust(account: account, asset: asset, remove: false, delegate: self)
    }

    func remove(_ asset: StellarAsset, from account: StellarAccount) {
        showHud(message: "REMOVING_ASSET".localized())
        accountService.changeTrust(account: account, asset: asset, remove: true, delegate: self)
    }

    private func reload() {
        guard let dataSource = delegate?.dataSource() else { return }
        assetListDataSource = dataSource
        assetListViewController.reload()
    }

    func displayAssetList() -> AppNavigationController {
        reload()
        return navController
    }

    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: navController.view, animated: true)
        hud.label.text = message
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: navController.view, animated: true)
    }
}

// MARK: - AssetActionDelegate
extension AssetCoordinator: AssetActionDelegate {
    /// This delegate method is called when the user taps the green add icon within an `AssetManageCell`
    func requestedAdd(asset: StellarAsset) {
        self.add(asset, to: account)
    }

    /// This delegate method is called when the user taps the red remove icon within an `AssetManageCell`
    func requestedRemove(asset: StellarAsset) {
        self.remove(asset, from: account)
    }

    func requestedAction(_ actionIndex: Int, for asset: StellarAsset) {
        if asset.isNative {
            guard actionIndex == 0 else { return }
            navController.pushViewController(inflationViewController, animated: true)
        }
    }
}

// MARK: - AssetListDelegate
extension AssetCoordinator: AssetListViewControllerDelegate {
    func requestedAddNewAsset(_ viewController: UIViewController) {
        guard account.hasRequiredNativeBalanceForNewEntry else {
            let minimumBalance = account.newEntryMinBalance.displayFormattedString
            assetListViewController.displayLowBalanceError(minimum: minimumBalance)
            return
        }

        navController.pushViewController(addAssetViewController, animated: true)
    }

    func requestedDismiss(_ viewController: UIViewController) {
        dismiss()
    }
}

extension AssetCoordinator: InflationViewControllerDelegate {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress) {
        guard destination.string != account.accountId, destination.string != account.inflationDestination else {
            UIAlertController.simpleAlert(title: "INVALID_DESTINATION_TITLE".localized(),
                                          message: "INFLATION_DESTINATION_INVALID".localized(),
                                          presentingViewController: inflationViewController)
            return
        }

        showHud(message: "SETTING_INFLATION_DESTINATION".localized())
        accountService.setInflationDestination(account: account, address: destination, delegate: self)
    }

    func clearAccountInflation(_ viewController: InflationViewController) {
        showHud(message: "CLEARING_INFLATION_DESTINATION".localized())
        accountService.setInflationDestination(account: account, address: nil, delegate: self)
    }

    func dismiss(_ viewController: InflationViewController) {
        navController.popViewController(animated: true)
        reload()
    }

    func inflationUpdateSuccess() {
        let message = Message(title: "INFLATION_SUCCESSFULLY_UPDATED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navController, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navController)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(self.inflationViewController)
            }
        }
    }
}

// MARK: - AssetSelectionDelegate
extension AssetCoordinator: AssetSelectionDelegate {
    func selected(_ asset: StellarAsset) {
        delegate?.selected(asset: asset)
        dismiss()
    }
}

// MARK: - AddAssetViewControllerDelegate
extension AssetCoordinator: AddAssetViewControllerDelegate {
    func requestedAdd(_ viewController: AddAssetViewController, asset: StellarAsset) {
        self.add(asset, to: account)
    }
}

// MARK: - ManageAssetResponseDelegate
extension AssetCoordinator: ManageAssetResponseDelegate {
    func added(asset: StellarAsset, account: StellarAccount) {
        reload()
        hideHud()
        delegate?.added(asset: asset, account: account)
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
        reload()
        hideHud()
        delegate?.removed(asset: asset, account: account)
    }

    func manageFailed(error: FrameworkError) {
        assetListViewController.displayFrameworkError(error, fallbackData: (title: "", message: ""))
    }
}

// MARK: - SetInflationResponseDelegate
extension AssetCoordinator: SetInflationResponseDelegate {
    func clearInflation() {
        hideHud()
        inflationUpdateSuccess()
    }

    func setInflation(destination: StellarAddress) {
        hideHud()
        inflationUpdateSuccess()
    }

    func inflationFailed(error: FrameworkError) {
        hideHud()
        let fallback = (title: "INFLATION_ERROR_TITLE".localized(), message: "INFLATION_ERROR_MESSAGE".localized())
        inflationViewController.displayFrameworkError(error, fallbackData: fallback)
    }
}

extension AssetCoordinator: AccountUpdatable {
    func updated(account: StellarAccount) {
        self.account = account
    }
}
