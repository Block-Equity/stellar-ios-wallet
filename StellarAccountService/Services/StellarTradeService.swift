//
//  StellarTradeService.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarTradeService: Subservice {
    typealias PostTradeOperationPair = ChainedOperationPair<FetchAccountDataOperation, PostTradeOperation>
    typealias CancelTradeOperationPair = ChainedOperationPair<FetchAccountDataOperation, CancelTradeOperation>

    public static let defaultRecordCount = 200
    public static let defaultTimeInterval = TimeInterval(30)

    let core: CoreService

    var tradeQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        return queue
    }

    internal init(with core: CoreService) {
        self.core = core
    }
}

extension StellarTradeService {
    public enum ServiceError: LocalizedError {
        case postTrade
        case cancelTrade
    }
}

// MARK: - Trades
extension StellarTradeService {
    public func postTrade(with data: StellarTradeOfferData, delegate: TradeResponseDelegate) {
        guard let keyPair = core.walletKeyPair else {
            delegate.postingFailed(error: ServiceError.postTrade)
            return
        }

        let completion: BoolCompletion = { posted in
            DispatchQueue.main.async {
                if posted {
                    delegate.posted(trade: data)
                } else {
                    delegate.postingFailed(error: ServiceError.postTrade)
                }
            }
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk, account: keyPair.accountId)
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
            delegate.cancellationFailed(error: ServiceError.cancelTrade)
            return
        }

        let completion: BoolCompletion = { cancelled in
            DispatchQueue.main.async {
                if cancelled {
                    delegate.cancelled(offerId: offerId, trade: data)
                } else {
                    delegate.cancellationFailed(error: ServiceError.cancelTrade)
                }
            }
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk, account: keyPair.accountId)
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
extension StellarTradeService {
    public func updateOrders(for pair: StellarAssetPair, delegate: OfferResponseDelegate) {
        let completion: FetchOrderBookOperation.SuccessCompletion = { response in
            let orders = StellarOrderbook(response: response)

            DispatchQueue.main.async {
                delegate.updated(orders: orders)
            }
        }

        let fetchOrdersOp = FetchOrderBookOperation(horizon: core.sdk,
                                                    assetPair: pair,
                                                    recordCount: StellarTradeService.defaultRecordCount,
                                                    completion: completion)

        tradeQueue.addOperation(fetchOrdersOp)
    }
}
