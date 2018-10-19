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

    public weak var tradeDelegate: TradeResponseDelegate?
    public weak var offerDelegate: OfferResponseDelegate?

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
    public func postTrade(with data: StellarTradeOfferData) {
        guard let keyPair = core.walletKeyPair else {
            tradeDelegate?.postingFailed(error: ServiceError.postTrade)
            return
        }

        let completion: BoolCompletion = { posted in
            DispatchQueue.main.async {
                if posted {
                    self.tradeDelegate?.posted(trade: data)
                } else {
                    self.tradeDelegate?.postingFailed(error: ServiceError.postTrade)
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

    public func cancelTrade(with offerId: Int, data: StellarTradeOfferData) {
        guard let keyPair = core.walletKeyPair else {
            tradeDelegate?.cancellationFailed(error: ServiceError.cancelTrade)
            return
        }

        let completion: BoolCompletion = { cancelled in
            DispatchQueue.main.async {
                if cancelled {
                    self.tradeDelegate?.cancelled(offerId: offerId, trade: data)
                } else {
                    self.tradeDelegate?.cancellationFailed(error: ServiceError.cancelTrade)
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
    public func updateOrders(for pair: StellarAssetPair) {
        let completion: FetchOrderBookOperation.SuccessCompletion = { response in
            let orders = StellarOrderbook(response: response)

            DispatchQueue.main.async {
                self.offerDelegate?.updated(orders: orders)
            }
        }

        let fetchOrdersOp = FetchOrderBookOperation(horizon: core.sdk,
                                                    assetPair: pair,
                                                    recordCount: StellarTradeService.defaultRecordCount,
                                                    completion: completion)

        tradeQueue.addOperation(fetchOrdersOp)
    }
}
