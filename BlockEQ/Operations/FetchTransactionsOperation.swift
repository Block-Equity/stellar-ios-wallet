//
//  FetchTransactionsOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import stellarsdk

final class FetchOperationEffectsOperation {
    static func getOperations(operation: String,
                              completion: @escaping ([StellarEffect]) -> Void,
                              failure: @escaping (String) -> Void) {
        Stellar.sdk.effects.getEffects(forOperation: operation) { effectResponse in
            switch effectResponse {
            case .success(let effects):
                let items: [StellarEffect] = effects.records.map {
                    print("Fetched effect \($0.id)")
                    return StellarEffect(effect: $0)

                }
                DispatchQueue.main.async { completion(items) }
            case .failure(let error):
                DispatchQueue.main.async { failure(error.localizedDescription) }
            }
        }
    }
}

final class FetchTransactionOperationsOperation {
    static func getOperations(transactionId: String,
                              completion: @escaping ([StellarOperation]) -> Void,
                              failure: @escaping (String) -> Void) {
        Stellar.sdk.operations.getOperations(forTransaction: transactionId) { response in
            switch response {
            case .success(let operationResponse):
                let operations: [StellarOperation] = operationResponse.records.map { operation in
                    print("Fetched operation \(operation.id)")
                    return StellarOperation(identifier: operation.id,
                                            createdAt: operation.createdAt,
                                            operationType: operation.operationTypeString)
                }

                DispatchQueue.main.async { completion(operations) }
            case .failure(let error):
                DispatchQueue.main.async { failure(error.localizedDescription) }
            }
        }
    }
}

final class FetchTransactionsOperation {
    static func getTransactions(accountId: String,
                                completion: @escaping ([StellarTransaction]) -> Void,
                                failure: @escaping (String) -> Void) {
        Stellar.sdk.transactions.getTransactions(forAccount: accountId, from: nil, order: nil, limit: nil) { response in
            switch response {
            case .success(let transactionsResponse):
                let transactions = transactionsResponse.records
                let stellarTransactions: [StellarTransaction] = transactions.map { item in
                    return StellarTransaction(account: item.sourceAccount,
                                              txId: item.id,
                                              ledger: item.ledger,
                                              createdAt: item.createdAt,
                                              feePaid: item.feePaid,
                                              memo: item.memo?.type(),
                                              memoType: item.memoType,
                                              operationCount: item.operationCount,
                                              sequence: item.sourceAccountSequence,
                                              signatures: item.signatures)
                }

                DispatchQueue.main.async { completion(stellarTransactions) }
            case .failure(let error):
                DispatchQueue.main.async { failure(error.localizedDescription) }
            }
        }
    }
}
