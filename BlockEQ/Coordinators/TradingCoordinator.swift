//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

protocol TradingCoordinatorDelegate: AnyObject {
    func setScroll(offset: CGFloat, page: Int)
}

protocol TradeAssetListDisplayable: AnyObject {
    func requestedDisplayAssetList(for: TradeViewController.TradeField)
}

final class TradingCoordinator {
    static let orderbookUpdateInterval: TimeInterval = 10

    let tradeService: TradeService

    let updateService: AccountUpdateService

    let accountService: AccountManagementService

    let segmentController: TradeSegmentViewController

    let tradeViewController: TradeViewController

    let orderBookViewController: OrderBookViewController

    let myOffersViewController: MyOffersViewController

    var assetCoordinator: AssetCoordinator?

    var assetPair: StellarAssetPair?

    var selectedTradeField: TradeViewController.TradeField?

    var tradeFromDataSource: TradeAssetListDataSource?

    var tradeToDataSource: TradeAssetListDataSource?

    var timer: Timer?

    weak var delegate: TradingCoordinatorDelegate?

    init(core: CoreService) {
        self.tradeService = core.tradeService
        self.updateService = core.updateService
        self.accountService = core.accountService

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
        tradeViewController.assetDelegate = self
        myOffersViewController.delegate = self

        let interval = TradingCoordinator.orderbookUpdateInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            guard let assetPair = self.assetPair else { return }
            self.tradeService.updateOrders(for: assetPair, delegate: self)
        })
    }

    func switchedSegment(_ type: TradeSegment) {
        segmentController.switchSegment(type)
    }

    deinit {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}

extension TradingCoordinator: TradeAssetListDisplayable {
    func requestedDisplayAssetList(for field: TradeViewController.TradeField) {
        guard let acct = self.accountService.account else {
            return
        }

        selectedTradeField = field

        let assetCoordinator = self.assetCoordinator ?? AssetCoordinator(accountService: accountService, account: acct)
        assetCoordinator.delegate = self

        self.assetCoordinator = assetCoordinator

        let navController = assetCoordinator.displayAssetList()
        segmentController.present(navController, animated: true, completion: nil)
    }
}

extension TradingCoordinator: AssetCoordinatorDelegate {
    func dataSource() -> AssetListDataSource? {
        guard let account = accountService.account else {
            return nil
        }

        let defaultDataSource = TradeAssetListDataSource(assets: account.assets, selected: nil, excluding: nil)

        guard let field = selectedTradeField else {
            return defaultDataSource
        }

        let accountAssets = account.assets

        switch field {
        case .fromAsset:
            return TradeAssetListDataSource(assets: accountAssets,
                                            selected: assetPair?.selling,
                                            excluding: nil)
        case .toAsset:
            return TradeAssetListDataSource(assets: accountAssets,
                                            selected: assetPair?.buying,
                                            excluding: assetPair?.selling)
        }
    }

    func selected(asset: StellarAsset) {
        defer {
            assetCoordinator = nil
            selectedTradeField = nil
            tradeFromDataSource = nil
            tradeToDataSource = nil
        }

        guard let tradeField = selectedTradeField, let account = accountService.account else {
            return
        }

        let previousFromAsset: StellarAsset? = assetPair?.selling
        let previousToAsset: StellarAsset? = assetPair?.buying
        var fromAsset: StellarAsset?
        var toAsset: StellarAsset?

        switch tradeField {
        case .fromAsset:
            fromAsset = asset
            toAsset = previousToAsset == asset ? account.firstAssetExcluding(fromAsset) : previousToAsset
        case .toAsset:
            toAsset = asset
            fromAsset = previousFromAsset == asset ? account.firstAssetExcluding(toAsset) : previousFromAsset
        }

        if let fromAsset = fromAsset, let toAsset = toAsset {
            let pair = StellarAssetPair(buying: toAsset, selling: fromAsset)

            getOrderBook(for: pair)
            tradeViewController.refreshView(pair: pair)

            assetPair = pair
        }
    }

    func dismissed(coordinator: AssetCoordinator, viewController: UIViewController) {
        assetCoordinator = nil
    }
}

extension TradingCoordinator: AccountUpdatable {
    func updated(account: StellarAccount) {

        if assetPair == nil, let account = accountService.account, account.assets.count > 1 {
            assetPair = StellarAssetPair(buying: account.assets[1], selling: account.assets[0])

            tradeFromDataSource = TradeAssetListDataSource(assets: account.assets,
                                                           selected: assetPair?.selling,
                                                           excluding: nil)

            tradeToDataSource = TradeAssetListDataSource(assets: account.assets,
                                                         selected: assetPair?.buying,
                                                         excluding: assetPair?.buying)
        }

        tradeViewController.refreshView(pair: assetPair)
        segmentController.updated(account: account)
        myOffersViewController.setOffers(account.tradeOffers)
    }
}

extension TradingCoordinator: TradeSegmentControllerDelegate {
    func setScroll(offset: CGFloat, page: Int) {
        delegate?.setScroll(offset: offset, page: page)
    }

    func displayAssetList() {
        self.requestedDisplayAssetList(for: .fromAsset)
    }
}

extension TradingCoordinator: TradeViewControllerDelegate {
    func scaledBalance(type: TradeViewController.BalanceType) -> Decimal {
        guard let asset = assetPair?.selling else { return 0 }
        return availableBalance(for: asset) * type.decimal
    }

    func availableBalance(for asset: StellarAsset) -> Decimal {
        guard let account = self.accountService.account else {
            return 0
        }

        return account.availableTradeBalance(for: asset)
    }

    func requestedRefresh() {
        tradeViewController.refreshView(pair: assetPair)
    }

    func requestTrade(type: StellarTradeOfferData.TradeType,
                      toAmount: String,
                      fromAmount: String,
                      numerator: Decimal,
                      denominator: Decimal) {
        guard let pair = assetPair else { return }

        let offerData = StellarTradeOfferData(type: type,
                                              assetPair: pair,
                                              price: Price(numerator: numerator, denominator: denominator),
                                              numerator: numerator,
                                              denominator: denominator,
                                              offerId: nil)

        tradeViewController.displayTradeConfirmation(fromAmount: fromAmount,
                                                     toAmount: toAmount,
                                                     pair: pair) {
            self.tradeViewController.showHud()
            self.tradeService.postTrade(with: offerData, delegate: self)
        }
    }

    func getOrderBook(for pair: StellarAssetPair) {
        guard pair.selling != pair.buying else { return }
        tradeService.updateOrders(for: pair, delegate: self)
    }
}

extension TradingCoordinator: TradeResponseDelegate {
    func cancelled(offerId: Int, trade: StellarTradeOfferData) {
        self.myOffersViewController.remove(offerId: offerId)
    }

    func posted(trade: StellarTradeOfferData) {
        self.updateService.update()
        self.tradeViewController.displayTradeSuccess()
    }

    func cancellationFailed(error: FrameworkError) {
        self.myOffersViewController.displayCancelFailure(error)
    }

    func postingFailed(error: FrameworkError) {
        self.tradeViewController.displayTradeError(error)
    }
}

extension TradingCoordinator: OfferResponseDelegate {
    func updated(offers: [StellarAccountOffer]) {
        self.myOffersViewController.setOffers(offers)
    }

    func updated(orders: StellarOrderbook) {
        self.orderBookViewController.setOrderBook(orderbook: orders)
        self.tradeViewController.setMarketPrice(orderbook: orders, assetPair: assetPair)
    }
}

extension TradingCoordinator: MyOffersViewControllerDelegate {
    func cancelTrade(offerId: Int, assetPair: StellarAssetPair, price: Price) {
        let tradeData = StellarTradeOfferData(offerId: offerId, assetPair: assetPair, price: price)
        tradeService.cancelTrade(with: offerId, data: tradeData, delegate: self)
    }
}
