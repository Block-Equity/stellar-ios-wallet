//
//  AccountUpdateService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-12-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class AccountUpdateService: AccountUpdateServiceProtocol {
    public static let longUpdateInterval: TimeInterval = 90
    public static let shortUpdateInterval: TimeInterval = 10

    let core: CoreServiceProtocol
    var account: StellarAccount?
    var lastFetch: TimeInterval?
    var timer: Timer?

    public var accountUpdateInterval: TimeInterval = longUpdateInterval {
        didSet {
            stopPeriodicUpdates()
            startPeriodicUpdates()
        }
    }

    var subscribers: MulticastDelegate<AccountUpdateServiceDelegate>

    lazy var updateQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }()

    init(with core: CoreServiceProtocol) {
        self.core = core
        self.subscribers = MulticastDelegate<AccountUpdateServiceDelegate>()
    }

    public func registerForUpdates<T: AccountUpdateServiceDelegate>(_ object: T) {
        subscribers.add(delegate: object)
    }

    public func unregisterForUpdates<T: AccountUpdateServiceDelegate>(_ object: T) {
        subscribers.remove(delegate: object)
    }

    /// Requests data that's occured between now and the last time data was fetched
    public func update() {
        guard let account = self.account else { return }

        let previousRawData = account.rawResponse

        // Trigger an account update notifying the delegate on the main thread
        self.update(account: account, using: core.sdk) { account, options in
            DispatchQueue.main.async {
                self.lastFetch = Date().timeIntervalSinceReferenceDate
                self.subscribers.invoke(invocation: { $0.accountUpdated(self, account: account, options: options) })

                if previousRawData == nil && account.rawResponse != nil {
                    self.subscribers.invoke(invocation: { $0.firstAccountUpdate(self, account: account) })
                }
            }
        }
    }

    deinit {
        stopPeriodicUpdates()
    }
}

extension AccountUpdateService {
    public struct UpdateOptions: OptionSet {
        public let rawValue: Int
        public static let inactive = UpdateOptions(rawValue: 1 << 0)
        public static let account = UpdateOptions(rawValue: 1 << 1)
        public static let transactions = UpdateOptions(rawValue: 1 << 2)
        public static let effects = UpdateOptions(rawValue: 1 << 3)
        public static let operations = UpdateOptions(rawValue: 1 << 4)
        public static let tradeOffers = UpdateOptions(rawValue: 1 << 5)

        public static let all: UpdateOptions = [.account, .transactions, .effects, .operations]
        public static let none: UpdateOptions = []

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Account Update
extension AccountUpdateService {
    internal func update(account: StellarAccount,
                         using sdk: StellarSDK,
                         completion: @escaping (StellarAccount, UpdateOptions) -> Void) {
        let accountId = account.accountId
        let address = account.address

        let fetchCompletion: FetchAccountDataOperation.SuccessCompletion = { response in
            account.update(withRaw: response)
            completion(account, UpdateOptions.account)
        }

        let failCompletion: ServiceErrorCompletion = { error in
            completion(account, UpdateOptions.inactive)
        }

        let fetchAccountOp = FetchAccountDataOperation(horizon: sdk,
                                                       account: accountId,
                                                       completion: fetchCompletion,
                                                       failure: failCompletion)

        // Fetch transactions
        let fetchTransactionOp = FetchTransactionsOperation(horizon: sdk, accountId: accountId, completion: { txns in
            account.mappedTransactions = txns.reduce(into: [:]) { map, transaction in
                map[transaction.identifier] = transaction
            }

            completion(account, UpdateOptions.transactions)
        })

        // Fetch operations
        let fetchOperationsOp = FetchAccountOperationsOperation(horizon: sdk, accountId: accountId, completion: { ops in
            account.mappedOperations = ops.reduce(into: [:], { result, operation in
                result[operation.identifier] = operation
            })

            completion(account, UpdateOptions.operations)
        })

        // Fetch effects
        let fetchEffectsOp = FetchAccountEffectsOperation(horizon: sdk, accountId: accountId, completion: { effects in
            account.mappedEffects = effects.reduce(into: [:], { list, effect in
                list[effect.identifier] = effect
            })

            completion(account, UpdateOptions.effects)
        })

        let fetchOffersOp = FetchOffersOperation(horizon: sdk, address: address, completion: { offers in
            account.mappedOffers = offers.reduce(into: [:], { list, offer in
                list[offer.identifier] = offer
            })

            account.outstandingTradeAmounts = offers.reduce(into: [:], { list, offer in
                let currentAmount = list[offer.sellingAsset] ?? 0
                list[offer.sellingAsset] = currentAmount + offer.amount
            })

            completion(account, UpdateOptions.tradeOffers)
        })

        let fetchOperations = [fetchAccountOp, fetchTransactionOp, fetchOperationsOp, fetchEffectsOp, fetchOffersOp]
        updateQueue.addOperations(fetchOperations, waitUntilFinished: false)
    }
}

// MARK: - Periodic updates
extension AccountUpdateService {
    public func startPeriodicUpdates() {
        setPeriodicTimer()
    }

    public func stopPeriodicUpdates() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    internal func setPeriodicTimer() {
        guard self.timer == nil else { return }

        self.timer = Timer.scheduledTimer(withTimeInterval: accountUpdateInterval, repeats: true, block: { _ in
            self.update()
        })
    }
}

extension AccountUpdateService: AccountManagementServiceDelegate {
    public func accountSwitched(_ service: AccountManagementService, account: StellarAccount) {
        self.account = account
    }
}

// MARK: - Subservice
extension AccountUpdateService {
    func reset() {
        subscribers.clear()

        account = nil
        lastFetch = nil
        stopPeriodicUpdates()
    }
}
