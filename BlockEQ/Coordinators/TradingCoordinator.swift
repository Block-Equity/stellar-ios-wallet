//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService
import stellarsdk

protocol AccountUpdatable: AnyObject {
    func updated(account: StellarAccount)
}

protocol TradingCoordinatorDelegate: AnyObject {
    func setScroll(offset: CGFloat, page: Int)
}

final class TradingCoordinator {
    var tradeService: StellarTradeService? {
        didSet {
            tradeService?.tradeDelegate = self
            tradeService?.offerDelegate = self
        }
    }

    private var account: StellarAccount? {
        didSet {
            guard let account = self.account else { return }

            segmentController.updated(account: account)
            tradeViewController.updated(account: account)
            myOffersViewController.setOffers(account.tradeOffers)
        }
    }

    let segmentController: TradeSegmentViewController

    let tradeViewController: TradeViewController

    let orderBookViewController: OrderBookViewController

    let myOffersViewController: MyOffersViewController

    var addAssetViewController: AddAssetViewController?

    var walletSwitchingViewController: WalletSwitchingViewController?

    var wrappingNavController: AppNavigationController?

    weak var delegate: TradingCoordinatorDelegate?

    init() {

        let tradeVC = TradeViewController()
        let orderBookVC = OrderBookViewController()
        let offersVC = MyOffersViewController()

        self.tradeViewController = tradeVC
        self.orderBookViewController = orderBookVC
        self.myOffersViewController = offersVC

        segmentController = TradeSegmentViewController(leftViewController: tradeViewController,
                                                       middleViewController: orderBookViewController,
                                                       rightViewController: myOffersViewController,
                                                       totalPages: CGFloat(TradeSegment.all.count))
        segmentController.tradeSegmentDelegate = self
        tradeViewController.delegate = self
        myOffersViewController.delegate = self
    }

    func switchedSegment(_ type: TradeSegment) {
        segmentController.switchSegment(type)
    }

    func displayAssetViewController() {
        if let account = self.account {
            let walletSwitchVC = WalletSwitchingViewController()
            walletSwitchVC.delegate = self
            walletSwitchingViewController = walletSwitchVC

            let container = AppNavigationController(rootViewController: walletSwitchVC)
            wrappingNavController = container
            wrappingNavController?.navigationBar.prefersLargeTitles = true

            walletSwitchVC.updateMenu(account: account)

            segmentController.present(container, animated: true, completion: nil)
        }
    }

    func update(with account: StellarAccount) {
        self.account = account
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
    func postTrade(data: StellarTradeOfferData) {
        tradeService?.postTrade(with: data)
    }

    func getOrderBook(for pair: StellarAssetPair) {
        tradeService?.updateOrders(for: pair)
    }

    func displayAddAssetForTrade() {
        displayAssetViewController()
    }
}

extension TradingCoordinator: WalletSwitchingViewControllerDelegate {
    func createTrustLine(to address: StellarAddress, for asset: StellarAsset) { }
    func switchWallet(to asset: StellarAsset) { }
    func reloadAssets() { }

    func remove(asset: StellarAsset) {
        self.account?.changeTrust(asset: asset, remove: true, delegate: self)
    }

    func add(asset: StellarAsset) {
        self.account?.changeTrust(asset: asset, remove: false, delegate: self)
    }

    func updateInflation(destination: StellarAddress) {
        guard let account = self.account else { return }

        let inflationViewController = InflationViewController(account: account, inflationDestination: destination)

        wrappingNavController?.pushViewController(inflationViewController, animated: true)
    }

    func selectedAddAsset() {
        let addAssetViewController = AddAssetViewController()
        addAssetViewController.delegate = self
        self.addAssetViewController = addAssetViewController

        wrappingNavController?.pushViewController(addAssetViewController, animated: true)
    }
}

extension TradingCoordinator: AddAssetViewControllerDelegate {
    func requestedAdd(_ viewController: AddAssetViewController, asset: StellarAsset) {
        guard let account = self.account else { return }

        walletSwitchingViewController?.updateMenu(account: account)
    }
}

extension TradingCoordinator: TradeResponseDelegate {
    func cancelled(offerId: Int, trade: StellarTradeOfferData) {
        self.myOffersViewController.remove(offerId: offerId)
    }

    func posted(trade: StellarTradeOfferData) {
        self.tradeViewController.displayTradeSuccess()
    }

    func cancellationFailed(error: Error) {
        self.myOffersViewController.displayCancelFailure()
    }

    func postingFailed(error: Error) {
        self.tradeViewController.displayTradeError()
    }
}

extension TradingCoordinator: OfferResponseDelegate {
    func updated(offers: [StellarAccountOffer]) {
        self.myOffersViewController.setOffers(offers)
    }

    func updated(orders: StellarOrderbook) {
        self.orderBookViewController.setOrderBook(orderbook: orders)
        self.tradeViewController.setMarketPrice(orderbook: orders)
    }
}

extension TradingCoordinator: MyOffersViewControllerDelegate {
    func cancelTrade(offerId: Int, assetPair: StellarAssetPair, price: Price) {
        let tradeData = StellarTradeOfferData(offerId: offerId, assetPair: assetPair, price: price)
        tradeService?.cancelTrade(with: offerId, data: tradeData)
    }
}

extension TradingCoordinator: ManageAssetResponseDelegate {
    func added(asset: StellarAsset, account: StellarAccount) {
        self.segmentController.updated(account: account)
        self.walletSwitchingViewController?.updateMenu(account: account)
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
        self.segmentController.updated(account: account)
        self.walletSwitchingViewController?.updateMenu(account: account)
    }

    func failed(error: Error) {
        self.walletSwitchingViewController?.hideHud()
        self.walletSwitchingViewController?.displayAssetActivationError()
    }
}
