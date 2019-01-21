//
//  TradeService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class TradeService: TradeServiceProtocol {
    typealias PostTradeOperationPair = ChainedOperationPair<FetchAccountDataOperation, PostTradeOperation>
    typealias CancelTradeOperationPair = ChainedOperationPair<FetchAccountDataOperation, CancelTradeOperation>

    public static let defaultRecordCount = 200

    let core: CoreServiceProtocol

    lazy var tradeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        return queue
    }()

    internal init(with core: CoreService) {
        self.core = core
    }
}

// MARK: - Subservice
extension TradeService {
    func reset() {
        tradeQueue.cancelAllOperations()
    }
}

// MARK: - Trades
extension TradeService {
    public func postTrade(with data: StellarTradeOfferData, delegate: TradeResponseDelegate) {
        guard let keyPair = core.walletKeyPair else {
            DispatchQueue.main.async {
                let wrappedError = FrameworkError(error: FrameworkError.TradeServiceError.postTrade)
                delegate.postingFailed(error: wrappedError)
            }
            return
        }

        let completion: ServiceErrorCompletion = { error in
            DispatchQueue.main.async {
                if let error = error {
                    delegate.postingFailed(error: error)
                } else {
                    delegate.posted(trade: data)
                }
            }
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk,
                                                  account: keyPair.accountId,
                                                  completion: nil,
                                                  failure: completion)

        let postTradeOp = PostTradeOperation(horizon: core.sdk,
                                             api: core.api,
                                             tradeData: data,
                                             userKeys: keyPair,
                                             completion: completion)

        let pair = PostTradeOperationPair(first: accountOp, second: postTradeOp)

        tradeQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }

    public func cancelTrade(with offerId: Int, data: StellarTradeOfferData, delegate: TradeResponseDelegate) {
        guard let keyPair = core.walletKeyPair else {
            DispatchQueue.main.async {
                let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.missingKeypair)
                delegate.cancellationFailed(error: wrappedError)
            }
            return
        }

        let completion: ServiceErrorCompletion = { error in
            DispatchQueue.main.async {
                if let error = error {
                    delegate.cancellationFailed(error: error)
                } else {
                    delegate.cancelled(offerId: offerId, trade: data)
                }
            }
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk,
                                                  account: keyPair.accountId,
                                                  completion: nil,
                                                  failure: completion)

        let cancelTradeOp = CancelTradeOperation(horizon: core.sdk,
                                                 api: core.api,
                                                 tradeData: data,
                                                 userKeys: keyPair,
                                                 completion: completion)

        let pair = CancelTradeOperationPair(first: accountOp, second: cancelTradeOp)

        tradeQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }
}

// MARK: - Orders & Offers
extension TradeService {
    public func updateOrders(for pair: StellarAssetPair, delegate: OfferResponseDelegate) {
        let completion: FetchOrderBookOperation.SuccessCompletion = { response in
            let orders = StellarOrderbook(response)

            DispatchQueue.main.async {
                delegate.updated(orders: orders)
            }
        }

        let fetchOrdersOp = FetchOrderBookOperation(horizon: core.sdk,
                                                    assetPair: pair,
                                                    recordCount: TradeService.defaultRecordCount,
                                                    completion: completion)

        tradeQueue.addOperation(fetchOrdersOp)
    }
}
