//
//  StellarAccount+Operations.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

extension StellarAccount {
    typealias SetInflationOperationPair = ChainedOperationPair<FetchAccountDataOperation, UpdateInflationOperation>
    typealias ChangeTrustOperationPair = ChainedOperationPair<ChangeAccountTrustOperation, FetchAccountDataOperation>

    internal func update(using sdk: StellarSDK, completion: @escaping (StellarAccount, UpdateOptions) -> Void) {
        let fetchCompletion: FetchAccountDataOperation.SuccessCompletion = { response in
            self.update(withRaw: response)
            completion(self, UpdateOptions.account)
        }

        let failCompletion: ErrorCompletion = { error in
            completion(self, UpdateOptions.inactive)
        }

        let fetchAccountOp = FetchAccountDataOperation(horizon: sdk,
                                                       account: accountId,
                                                       completion: fetchCompletion,
                                                       failure: failCompletion)

        // Fetch transactions
        let fetchTransactionOp = FetchTransactionsOperation(horizon: sdk, accountId: accountId, completion: { txns in
            self.mappedTransactions = txns.reduce(into: [:]) { map, transaction in
                map[transaction.identifier] = transaction
            }

            completion(self, UpdateOptions.transactions)
        })

        // Fetch operations
        let fetchOperationsOp = FetchAccountOperationsOperation(horizon: sdk, accountId: accountId, completion: { ops in
            self.mappedOperations = ops.reduce(into: [:], { result, operation in
                result[operation.identifier] = operation
            })

            completion(self, UpdateOptions.operations)
        })

        // Fetch effects
        let fetchEffectsOp = FetchAccountEffectsOperation(horizon: sdk, accountId: accountId, completion: { effects in
            self.mappedEffects = effects.reduce(into: [:], { list, effect in
                list[effect.identifier] = effect
            })

            completion(self, UpdateOptions.effects)
        })

        let fetchOffersOp = FetchOffersOperation(horizon: sdk, address: address, completion: { offers in
            self.mappedOffers = offers.reduce(into: [:], { list, offer in
                list[offer.identifier] = offer
            })

            completion(self, UpdateOptions.tradeOffers)
        })

        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        let fetchOperations = [fetchAccountOp, fetchTransactionOp, fetchOperationsOp, fetchEffectsOp, fetchOffersOp]
        queue.addOperations(fetchOperations, waitUntilFinished: false)
    }

    public func setInflationDestination(address: StellarAddress, delegate: SetInflationResponseDelegate) {
        inflationResponseDelegate = delegate

        let completion: BoolCompletion = { completed in
            if completed {
                DispatchQueue.main.async {
                    self.inflationDestination = address.string
                    self.inflationResponseDelegate?.setInflation(destination: address)
                    self.inflationResponseDelegate = nil
                }
            } else {
                DispatchQueue.main.async {
                    let error = StellarAccountService.ServiceError.nonExistentAccount
                    self.inflationResponseDelegate?.failed(error: error)
                    self.inflationResponseDelegate = nil
                }
            }
        }

        guard let service = self.service, let keyPair = service.core.walletKeyPair else {
            self.inflationResponseDelegate?.failed(error: StellarAccountService.ServiceError.nonExistentAccount)
            return

        }

        let accountOp = FetchAccountDataOperation(horizon: service.core.sdk, account: accountId)
        let inflationOp = UpdateInflationOperation(horizon: service.core.sdk,
                                                   api: service.core.api,
                                                   address: address,
                                                   userKeys: keyPair,
                                                   completion: completion)

        let pair = SetInflationOperationPair(first: accountOp, second: inflationOp)
        accountQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }

//swiftlint:disable function_body_length
    public func sendAmount(data: StellarPaymentData, delegate: SendAmountResponseDelegate) {
        sendResponseDelegate = delegate

        let completion: BoolCompletion = { completed in
            if completed {
                DispatchQueue.main.async {
                    self.sendResponseDelegate?.sentAmount(destination: data.address)
                    self.sendResponseDelegate = nil
                }
            } else {
                DispatchQueue.main.async {
                    let error = StellarAccountService.ServiceError.nonExistentAccount
                    self.sendResponseDelegate?.failed(error: error)
                    self.sendResponseDelegate = nil
                }
            }
        }

        guard let service = self.service, let keyPair = service.core.walletKeyPair else {
            self.sendResponseDelegate?.failed(error: StellarAccountService.ServiceError.nonExistentAccount)
                return
        }

        let checkAccountOp = FetchAccountDataOperation(horizon: service.core.sdk,
                                                       account: data.address.string,
                                                       completion: nil,
                                                       failure: nil)

        let createOp = CreateNewAccountOperation(horizon: service.core.sdk,
                                                 api: service.core.api,
                                                 accountId: data.address.string,
                                                 amount: data.amount,
                                                 userKeys: keyPair,
                                                 completion: completion)

        let sendOp = PostPaymentOperation(horizon: service.core.sdk,
                                          api: service.core.api,
                                          data: data,
                                          userKeyPair: keyPair,
                                          completion: completion)

        let refreshOp = FetchAccountDataOperation(horizon: service.core.sdk,
                                                  account: self.address.string,
                                                  completion: { response in
            self.update(withRaw: response)

            DispatchQueue.main.async {
                service.delegate?.accountUpdated(service, account: self, opts: .account)
            }
        })

        let accComp: FetchAccountDataOperation.SuccessCompletion = { account in
            sendOp.inData = self.rawResponse
            refreshOp.removeDependency(createOp)
            createOp.cancel()
        }

        let accFail: ErrorCompletion = { _ in
            createOp.inData = self.rawResponse
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
//swiftlint:enable function_body_length

    public func changeTrust(asset: StellarAsset, remove: Bool, delegate: ManageAssetResponseDelegate) {
        manageAssetResponseDelegate = delegate

        guard let accountResponse = self.rawResponse else {
            delegate.failed(error: StellarAccountService.ServiceError.nonExistentAccount)
            return
        }

        let completion: FetchAccountDataOperation.SuccessCompletion = { response in
            self.update(withRaw: response)

            if remove {
                DispatchQueue.main.async {
                    self.manageAssetResponseDelegate?.removed(asset: asset, account: self)
                    self.manageAssetResponseDelegate = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.manageAssetResponseDelegate?.added(asset: asset, account: self)
                    self.manageAssetResponseDelegate = nil
                }
            }
        }

        let trustCompletion: BoolCompletion = { completed in
            guard completed != true else { return }
            DispatchQueue.main.async {
                let error = StellarAccountService.ServiceError.nonExistentAccount
                self.manageAssetResponseDelegate?.failed(error: error)
                self.manageAssetResponseDelegate = nil
            }
        }

        guard let service = self.service, let keyPair = service.core.walletKeyPair else {
            self.manageAssetResponseDelegate?.failed(error: StellarAccountService.ServiceError.nonExistentAccount)
            return
        }

        let accountOp = FetchAccountDataOperation(horizon: service.core.sdk, account: accountId, completion: completion)
        let changeTrustOp = ChangeAccountTrustOperation(horizon: service.core.sdk,
                                                        api: service.core.api,
                                                        asset: asset,
                                                        limit: remove ? Decimal(0.0) : nil,
                                                        accountResponse: accountResponse,
                                                        userKeyPair: keyPair,
                                                        completion: trustCompletion)

        let pair = ChangeTrustOperationPair(first: changeTrustOp, second: accountOp)
        accountQueue.addOperations(pair.operationChain, waitUntilFinished: false)
    }
}
