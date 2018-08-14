//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

protocol TradingCoordinatorDelegate: AnyObject {
    func setScroll(offset: CGFloat, page: Int)
}

final class TradingCoordinator {
    let segmentController: TradeSegmentViewController!

    var delegate: TradingCoordinatorDelegate?

    var stellarAccount: StellarAccount?

    var addAssetViewController: AddAssetViewController?

    var tradeViewController: TradeViewController = {
        let vc = TradeViewController()
        return vc
    }()

    var orderBookViewController: OrderBookViewController = {
        let vc = OrderBookViewController()
        return vc
    }()

    var myOffersViewController: MyOffersViewController = {
        let vc = MyOffersViewController()
        return vc
    }()

    var walletSwitchingViewController: WalletSwitchingViewController?
    var wrappingNavController: AppNavigationController?

    init() {
        segmentController = TradeSegmentViewController(leftViewController: tradeViewController, middleViewController: orderBookViewController, rightViewController: myOffersViewController, totalPages: CGFloat(TradeSegment.all.count))
        segmentController.tradeSegmentDelegate = self
        tradeViewController.delegate = self
    }

    func switchedSegment(_ type: TradeSegment) {
        segmentController.switchSegment(type)
    }

    func displayAssetViewController() {
        if let account = self.stellarAccount {
            let walletSwitchVC = WalletSwitchingViewController()
            walletSwitchVC.delegate = self
            walletSwitchingViewController = walletSwitchVC

            let container = AppNavigationController(rootViewController: walletSwitchVC)
            wrappingNavController = container
            wrappingNavController?.navigationBar.prefersLargeTitles = true

            walletSwitchVC.updateMenu(stellarAccount: account)

            segmentController.present(container, animated: true, completion: nil)
        }
    }
}

extension TradingCoordinator: TradeSegmentControllerDelegate {
    func setScroll(offset: CGFloat, page: Int) {
        delegate?.setScroll(offset: offset, page: page)
    }

    func displayAddAsset() {
        displayAssetViewController()
    }
}

extension TradingCoordinator: TradeViewControllerDelegate {
    func getOrderBook(sellingAsset: StellarAsset, buyingAsset: StellarAsset) {
        requestOrderBook(sellingAsset: sellingAsset, buyingAsset: buyingAsset)
    }

    func displayNoAssetOverlay() {
        segmentController.displayNoAssetOverlayView()
    }

    func hideNoAssetOverlay() {
        segmentController.hideNoAssetOverlayView()
    }

    func displayAddAssetForTrade() {
        displayAssetViewController()
    }

    func update(stellarAccount: StellarAccount) {
        self.stellarAccount = stellarAccount
    }
}

extension TradingCoordinator: WalletSwitchingViewControllerDelegate {
    func didSelectSetInflation(inflationDestination: String?) {
        let inflationViewController = InflationViewController(inflationDestination: inflationDestination)

        wrappingNavController?.pushViewController(inflationViewController, animated: true)
    }

    func didSelectAddAsset() {
        let addAssetViewController = AddAssetViewController()
        addAssetViewController.delegate = self
        self.addAssetViewController = addAssetViewController

        wrappingNavController?.pushViewController(addAssetViewController, animated: true)
    }

    func didSelectAsset(index: Int) {}

    func reloadAssets() {}
}

extension TradingCoordinator: AddAssetViewControllerDelegate {
    func didAddAsset(stellarAccount: StellarAccount) {
        reloadAssets()

        walletSwitchingViewController?.updateMenu(stellarAccount: stellarAccount)
    }
}

extension TradingCoordinator {
    func requestOrderBook(sellingAsset: StellarAsset, buyingAsset: StellarAsset) {
        TradeOperation.getOrderBook(sellingAsset: sellingAsset, buyingAsset: buyingAsset, completion: { response in
            self.orderBookViewController.setOrderBook(orderBook: response, buyAsset: buyingAsset, sellAsset: sellingAsset)
            self.tradeViewController.setMarketPrice(orderBook: response)
        }) { error in
            print(error)
        }

        getPendingOffers()
    }

    func getPendingOffers() {
        TradeOperation.getOffers(completion: { response in
            self.myOffersViewController.setOffers(offers: response)
        }) { error in
            print("Error", error)
        }
    }
}
