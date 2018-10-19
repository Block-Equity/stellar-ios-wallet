//
//  FetchTransactionsOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchTransactionsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarTransaction]) -> Void

    let horizon: StellarSDK
    let accountId: String
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<[StellarTransaction]> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         accountId: String,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.accountId = accountId
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.transactions.getTransactions(forAccount: accountId, from: nil, order: .ascending, limit: 200) { resp in
            switch resp {
            case .success(let response):
                let transactions = response.records

                let stellarTransactions: [StellarTransaction] = transactions.map { item in
                    return StellarTransaction(account: item.sourceAccount,
                                              txId: item.id,
                                              ledger: item.ledger,
                                              createdAt: item.createdAt,
                                              feePaid: item.feePaid,
                                              memo: item.memo,
                                              memoType: item.memoType,
                                              operationCount: item.operationCount,
                                              sequence: item.sourceAccountSequence,
                                              signatures: item.signatures)
                }
                self.result = Result.success(stellarTransactions)
            case .failure(let error):
                self.result = Result.failure(error)
            }

            self.finish()
        }
    }

    func finish() {
        state = .finished

        switch result {
        case .success(let response):
            completion(response)
        case .failure(let error):
            failure?(error)
        }
    }
}
