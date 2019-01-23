//
//  StellarHub+Operations.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-11-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

// MARK: - Inflation Update
extension AccountManagementService {
    typealias SetInflationOperationPair = ChainedOperationPair<FetchAccountDataOperation, UpdateInflationOperation>

    public func setInflationDestination(account: StellarAccount,
                                        address: StellarAddress?,
                                        delegate: SetInflationResponseDelegate) {
        let completion: ServiceErrorCompletion = { error in
            DispatchQueue.main.async {
                if let error = error {
                    delegate.inflationFailed(error: error)
                } else if let inflationAddress = address {
                    account.inflationDestination = inflationAddress.string
                    delegate.setInflation(destination: inflationAddress)
                } else {
                    account.inflationDestination = nil
                    delegate.clearInflation()
                }
            }
        }

        guard let keyPair = core.walletKeyPair else {
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.missingKeypair)
            delegate.inflationFailed(error: wrappedError)
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
extension AccountManagementService {
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
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.missingKeypair)
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
//            DispatchQueue.main.async {
//                self.subscribers.invoke(invocation: { $0.accountUpdated(self, account: account, opts: .account) })
//            }
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
extension AccountManagementService {
    typealias ChangeTrustOperationPair = ChainedOperationPair<ChangeAccountTrustOperation, FetchAccountDataOperation>

    public func changeTrust(account: StellarAccount,
                            asset: StellarAsset,
                            remove: Bool,
                            delegate: ManageAssetResponseDelegate) {
        let accountId = account.accountId

        guard let accountResponse = account.rawResponse else {
            DispatchQueue.main.async {
                let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.nonExistentAccount)
                delegate.manageFailed(error: wrappedError)
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
                delegate.manageFailed(error: FrameworkError(error: error))
            }
        }

        guard let keyPair = core.walletKeyPair else {
            let wrappedError = FrameworkError(error: FrameworkError.AccountServiceError.missingKeypair)
            delegate.manageFailed(error: wrappedError)
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
