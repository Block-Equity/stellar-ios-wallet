//
//  StellarAccountService+Operations.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-11-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

extension StellarAccountService {
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
extension StellarAccountService {
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

            completion(account, UpdateOptions.tradeOffers)
        })

        let fetchOperations = [fetchAccountOp, fetchTransactionOp, fetchOperationsOp, fetchEffectsOp, fetchOffersOp]
        accountQueue.addOperations(fetchOperations, waitUntilFinished: false)
    }
}

// MARK: - Inflation Update
extension StellarAccountService {
    typealias SetInflationOperationPair = ChainedOperationPair<FetchAccountDataOperation, UpdateInflationOperation>

    public func setInflationDestination(account: StellarAccount,
                                        address: StellarAddress,
                                        delegate: SetInflationResponseDelegate) {
        let completion: ServiceErrorCompletion = { error in
            DispatchQueue.main.async {
                if let error = error {
                    delegate.failed(error: error)
                } else {
                    account.inflationDestination = address.string
                    delegate.setInflation(destination: address)
                }
            }
        }

        guard let keyPair = core.walletKeyPair else {
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.nonExistentAccount)
            delegate.failed(error: wrappedError)
            return
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk, account: account.accountId)
        let inflationOp = UpdateInflationOperation(horizon: core.sdk,
                                                   api: core.api,
                                                   address: address,
                                                   userKeys: keyPair,
                                                   completion: completion)

        let pair = SetInflationOperationPair(first: accountOp, second: inflationOp)
        accountQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }
}

// MARK: - Send Amount
//swiftlint:disable function_body_length
extension StellarAccountService {
    public func sendAmount(account: StellarAccount, data: StellarPaymentData, delegate: SendAmountResponseDelegate) {
        let completion: ServiceErrorCompletion = { error in
            DispatchQueue.main.async {
                if let error = error {
                    delegate.failed(error: error)
                } else {
                    delegate.sentAmount(destination: data.address)
                }
            }
        }

        guard let keyPair = core.walletKeyPair else {
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.nonExistentAccount)
            delegate.failed(error: wrappedError)
            return
        }

        let checkAccountOp = FetchAccountDataOperation(horizon: core.sdk,
                                                       account: data.address.string,
                                                       completion: nil,
                                                       failure: nil)

        let createOp = CreateNewAccountOperation(horizon: core.sdk,
                                                 api: core.api,
                                                 accountId: data.address.string,
                                                 amount: data.amount,
                                                 userKeys: keyPair,
                                                 completion: completion)

        let sendOp = PostPaymentOperation(horizon: core.sdk,
                                          api: core.api,
                                          data: data,
                                          userKeyPair: keyPair,
                                          completion: completion)

        let refreshOp = FetchAccountDataOperation(horizon: core.sdk,
                                                  account: account.address.string,
                                                  completion: { response in
                                                    account.update(withRaw: response)
            DispatchQueue.main.async {
                self.subscribers.invoke(invocation: { $0.accountUpdated(self, account: account, opts: .account) })
            }
        })

        let accComp: FetchAccountDataOperation.SuccessCompletion = { accountResponse in
            sendOp.inData = account.rawResponse
            refreshOp.removeDependency(createOp)
            createOp.cancel()
        }

        let accFail: ServiceErrorCompletion = { _ in
            createOp.inData = account.rawResponse
            refreshOp.removeDependency(sendOp)
            sendOp.cancel()
        }

        checkAccountOp.completion = accComp
        checkAccountOp.failure = accFail

        createOp.addDependency(checkAccountOp)
        sendOp.addDependency(checkAccountOp)
        refreshOp.addDependency(sendOp)
        refreshOp.addDependency(createOp)

        accountQueue.addOperations([checkAccountOp, sendOp, createOp, refreshOp], waitUntilFinished: false)
    }
}
//swiftlint:enable function_body_length

// MARK: - Change Trust
extension StellarAccountService {
    typealias ChangeTrustOperationPair = ChainedOperationPair<ChangeAccountTrustOperation, FetchAccountDataOperation>

    public func changeTrust(account: StellarAccount,
                            asset: StellarAsset,
                            remove: Bool,
                            delegate: ManageAssetResponseDelegate) {
        let accountId = account.accountId

        guard let accountResponse = account.rawResponse else {
            DispatchQueue.main.async {
                let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.nonExistentAccount)
                delegate.failed(error: wrappedError)
            }
            return
        }

        let completion: FetchAccountDataOperation.SuccessCompletion = { response in
            account.update(withRaw: response)

            DispatchQueue.main.async {
                if remove {
                    delegate.removed(asset: asset, account: account)
                } else {
                    delegate.added(asset: asset, account: account)
                }
            }
        }

        let trustCompletion: ServiceErrorCompletion = { error in
            guard let error = error else { return }

            DispatchQueue.main.async {
                delegate.failed(error: FrameworkError(error: error))
            }
        }

        guard let keyPair = core.walletKeyPair else {
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.nonExistentAccount)
            delegate.failed(error: wrappedError)
            return
        }

        let accountOp = FetchAccountDataOperation(horizon: core.sdk, account: accountId, completion: completion)
        let changeTrustOp = ChangeAccountTrustOperation(horizon: core.sdk,
                                                        api: core.api,
                                                        asset: asset,
                                                        limit: remove ? Decimal(0.0) : nil,
                                                        accountResponse: accountResponse,
                                                        userKeyPair: keyPair,
                                                        completion: trustCompletion)

        let pair = ChangeTrustOperationPair(first: changeTrustOp, second: accountOp)
        accountQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }
}
