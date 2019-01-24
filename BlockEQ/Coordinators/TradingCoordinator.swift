//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk
import Whisper

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

    let orderbookViewController: OrderbookViewController

    let myOffersViewController: MyOffersViewController

    var assetCoordinator: AssetCoordinator?

    var assetPair: StellarAssetPair?

    var selectedTradeField: TradeViewController.TradeField?

    var tradeFromDataSource: TradeAssetListDataSource?

    var tradeToDataSource: TradeAssetListDataSource?

    var timer: Timer?

    weak var delegate: TradingCoordinatorDelegate?

    init(core: CoreService) {
        let tradeVC = TradeViewController()
        let orderBookVC = OrderbookViewController()
        let offersVC = MyOffersViewController()

        tradeService = core.tradeService
        updateService = core.updateService
        accountService = core.accountService

        tradeViewController = tradeVC
        orderbookViewController = orderBookVC
        myOffersViewController = offersVC

        _ = tradeVC.view
        _ = orderBookVC.view
        _ = offersVC.view

        segmentController = TradeSegmentViewController(leftViewController: tradeViewController,
                                                       middleViewController: orderbookViewController,
                                                       rightViewController: myOffersViewController,
                                                       totalPages: CGFloat(TradeSegment.all.count))
        segmentController.tradeSegmentDelegate = self
        tradeViewController.delegate = self
        tradeViewController.assetDelegate = self
        myOffersViewController.delegate = self
        orderbookViewController.delegate = self
    }

    func switchedSegment(_ type: TradeSegment) -> Bool {
        return segmentController.switchSegment(type)
    }

    func startPeriodicOrderbookUpdates() {
        guard timer == nil else { return }

        let interval = TradingCoordinator.orderbookUpdateInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            guard let assetPair = self.assetPair else { return }
            self.tradeService.updateOrders(for: assetPair, delegate: self)
        })
    }

    func stopPeriodicOrderbookUpdates() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopPeriodicOrderbookUpdates()
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
    func added(asset: StellarAsset, account: StellarAccount) {
        updated(account: account)
    }

    func removed(asset: StellarAsset, account: StellarAccount) {
    }

    func dataSource() -> AssetListDataSource? {
        guard let account = accountService.account else {
            return nil
        }

        let defaultDataSource = TradeAssetListDataSource(account: account,
                                                         assets: account.assets,
                                                         availableAssets: [],
                                                         selected: nil,
                                                         excluding: nil)

        guard let field = selectedTradeField else {
            return defaultDataSource
        }

        switch field {
        case .fromAsset:
            return TradeAssetListDataSource(account: account,
                                            assets: account.assets,
                                            availableAssets: account.availableAssets,
                                            selected: assetPair?.selling,
                                            excluding: nil)
        case .toAsset:
            return TradeAssetListDataSource(account: account,
                                            assets: account.assets,
                                            availableAssets: account.availableAssets,
                                            selected: assetPair?.buying,
                                            excluding: assetPair?.selling)
        case .firstTimeAdd:
            let assets = account.assets.count > 1 ? account.assets : account.availableAssets
            return TradeAssetListDataSource(account: account,
                                            assets: assets,
                                            availableAssets: account.availableAssets,
                                            selected: nil,
                                            excluding: account.assets.first)
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
        default: break
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

// MARK: - Prompts
extension TradingCoordinator {
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: segmentController.view, animated: true)
        hud.label.text = "TRADE_SUBMITTING_MESSAGE".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: segmentController.view, animated: true)
    }

    func displayTradeSuccess() {
        hideHud()

        guard let navController = segmentController.navigationController else { return }

        let message = Message(title: "TRADE_SUBMITTED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navController, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: navController)
        }
    }

    func displayTradeError(_ error: FrameworkError) {
        hideHud()

        let fallbackTitle = "TRANSACTION_ERROR_TITLE".localized()
        let fallbackMessage = "TRANSACTION_ERROR_MESSAGE".localized()

        tradeViewController.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }

    func displayTradeConfirmation(fromAmount: String,
                                  toAmount: String,
                                  pair: StellarAssetPair,
                                  confirmed: @escaping () -> Void) {
        let format = "SUBMIT_TRADE_FORMAT".localized()
        let alertMessage = String(format: format, fromAmount, pair.selling.shortCode, toAmount, pair.buying.shortCode)
        let cancelAction = UIAlertAction(title: "CANCEL_ACTION".localized(), style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "TRADE_TITLE".localized(), style: .default, handler: { _ in
            confirmed()
        })

        let alert = UIAlertController(title: "SUBMIT_TRADE_TITLE".localized(),
                                      message: alertMessage,
                                      preferredStyle: .alert)

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        tradeViewController.present(alert, animated: true, completion: nil)
    }
}

extension TradingCoordinator: AccountUpdatable {
    func updated(account: StellarAccount) {
        if assetPair == nil, let account = accountService.account, account.assets.count > 1 {
            let pair = StellarAssetPair(buying: account.assets[1], selling: account.assets[0])
            assetPair = pair

            tradeFromDataSource = TradeAssetListDataSource(account: account,
                                                           assets: account.assets,
                                                           availableAssets: account.availableAssets,
                                                           selected: pair.selling,
                                                           excluding: nil)

            tradeToDataSource = TradeAssetListDataSource(account: account,
                                                         assets: account.assets,
                                                         availableAssets: account.availableAssets,
                                                         selected: pair.buying,
                                                         excluding: pair.buying)

            tradeService.updateOrders(for: pair, delegate: self)
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
        self.requestedDisplayAssetList(for: .firstTimeAdd)
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

        displayTradeConfirmation(fromAmount: fromAmount, toAmount: toAmount, pair: pair) {
            self.showHud()
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
        myOffersViewController.remove(offerId: offerId)
    }

    func posted(trade: StellarTradeOfferData) {
        tradeViewController.clearTradeFields()
        updateService.update()
        displayTradeSuccess()
    }

    func cancellationFailed(error: FrameworkError) {
        myOffersViewController.displayCancelFailure(error)
    }

    func postingFailed(error: FrameworkError) {
        displayTradeError(error)
    }
}

extension TradingCoordinator: OfferResponseDelegate {
    func updated(offers: [StellarAccountOffer]) {
        myOffersViewController.setOffers(offers)
    }

    func updated(orders: StellarOrderbook) {
        self.orderbookViewController.setOrderBook(orderbook: orders)
        self.tradeViewController.setMarketPrice(orderbook: orders, assetPair: assetPair)
    }
}

extension TradingCoordinator: MyOffersViewControllerDelegate {
    func cancelTrade(offerId: Int, assetPair: StellarAssetPair, price: Price) {
        let tradeData = StellarTradeOfferData(offerId: offerId, assetPair: assetPair, price: price)
        tradeService.cancelTrade(with: offerId, data: tradeData, delegate: self)
    }
}

extension TradingCoordinator: OrderbookViewControllerDelegate {
    func requestedTogglePeriodicUpdates(enabled: Bool) {
        enabled ? startPeriodicOrderbookUpdates() : stopPeriodicOrderbookUpdates()
    }
}
