//
//  AssetCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-01.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

protocol ManageAssetDisplayable: AnyObject {
    func displayLoading(for asset: StellarAsset?)
    func hideLoading()
    func displayError(error: FrameworkError)
}

protocol AssetCoordinatorDelegate: AnyObject {
    func selected(asset: StellarAsset)
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

protocol AssetListDataSource: (UICollectionViewDelegate & UICollectionViewDataSource) {
    var actionDelegate: AssetActionDelegate? { get set }
    var selectionDelegate: AssetSelectionDelegate? { get set }
}

final class AssetCoordinator {
    private var account: StellarAccount

    private let accountService: AccountManagementService

    private var assetNavController: UINavigationController?

    private var addAssetViewController: AddAssetViewController?

    private var assetListViewController: AssetListViewController?

    private var assetListDataSource: AssetListDataSource? {
        didSet {
            assetListViewController?.dataSource = assetListDataSource
        }
    }

    /// The view controller used to set the user's inflation pool, deallocated once finished using
    var inflationViewController: InflationViewController?

    weak var delegate: AssetCoordinatorDelegate?

    init(accountService: AccountManagementService, account: StellarAccount) {
        self.account = account
        self.accountService = accountService
    }

    func dismiss() {
        guard let viewController = assetNavController else {
            return
        }

        viewController.dismiss(animated: true) {
            self.delegate?.dismissed(coordinator: self, viewController: viewController)
        }
    }

    func add(_ asset: StellarAsset, to account: StellarAccount) {
        assetListViewController?.displayLoading(for: nil)
        accountService.changeTrust(account: account, asset: asset, remove: false, delegate: self)
    }

    func remove(_ asset: StellarAsset, from account: StellarAccount) {
        assetListViewController?.displayLoading(for: asset)
        accountService.changeTrust(account: account, asset: asset, remove: true, delegate: self)
    }

    private func reload() {
        guard let dataSource = delegate?.dataSource() else { return }
        dataSource.actionDelegate = self
        dataSource.selectionDelegate = self

        assetListViewController?.dataSource = dataSource
        assetListDataSource = dataSource
    }

    func assetList(addEnabled: Bool = true) -> AssetListViewController {
        let assetVC = assetListViewController ?? AssetListViewController()
        assetVC.delegate = self

        // Force the view hierarchy to load in order to set the collection view's outlets
        _ = assetVC.view

        assetVC.addAssetView.isHidden = !addEnabled

        if let dataSource = delegate?.dataSource() {
            dataSource.actionDelegate = self
            dataSource.selectionDelegate = self

            assetVC.dataSource = dataSource
            assetListDataSource = dataSource
        }

        return assetVC
    }

    func displayAssetList(addEnabled: Bool = true, largeTitle: Bool = true) -> AppNavigationController {
        let assetVC = self.assetList(addEnabled: addEnabled)

        let navController = AppNavigationController(rootViewController: assetVC)
        navController.navigationBar.prefersLargeTitles = largeTitle

        assetNavController = navController
        assetListViewController = assetVC

        return navController
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

            let inflationVC = inflationViewController ?? InflationViewController(account: account)
            inflationVC.delegate = self

            self.inflationViewController = inflationVC

            assetNavController?.pushViewController(inflationVC, animated: true)
        }
    }
}

// MARK: - AssetListDelegate
extension AssetCoordinator: AssetListViewControllerDelegate {
    func requestedAddNewAsset(_ viewController: UIViewController) {

        guard account.hasRequiredNativeBalanceForNewEntry else {
            let minimumBalance = account.newEntryMinBalance.displayFormattedString
            assetListViewController?.displayLowBalanceError(minimum: minimumBalance)
            return
        }

        let addVC = addAssetViewController ?? AddAssetViewController()
        addVC.delegate = self

        assetNavController?.pushViewController(addVC, animated: true)
    }

    func requestedDismiss(_ viewController: UIViewController) {
        dismiss()
    }
}

extension AssetCoordinator: InflationViewControllerDelegate {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress) {
        accountService.setInflationDestination(account: account, address: destination, delegate: self)
    }

    func dismiss(_ viewController: InflationViewController) {
        assetNavController?.popViewController(animated: true)

        if let dataSource = delegate?.dataSource() {
            dataSource.actionDelegate = self
            dataSource.selectionDelegate = self
            self.assetListDataSource = dataSource

            assetListViewController?.dataSource = dataSource
            assetListViewController?.reload()
        }

        inflationViewController = nil
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
        assetListViewController?.hideLoading()
        assetListViewController?.reload()
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
        reload()
        assetListViewController?.hideLoading()
        assetListViewController?.reload()
    }

    func manageFailed(error: FrameworkError) {
        assetListViewController?.displayError(error: error)
    }
}

// MARK: - SetInflationResponseDelegate
extension AssetCoordinator: SetInflationResponseDelegate {
    func setInflation(destination: StellarAddress) {
        inflationViewController?.displayInflationSuccess()
    }

    func inflationFailed(error: FrameworkError) {
        inflationViewController?.displayError(error: error)
    }
}

extension AssetCoordinator: AccountUpdatable {
    func updated(account: StellarAccount) {
        self.account = account
    }
}
