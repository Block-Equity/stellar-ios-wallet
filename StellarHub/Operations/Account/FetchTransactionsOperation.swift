//
//  FetchTransactionsOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchTransactionsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarTransaction]) -> Void

    static let defaultRecordCount: Int = 200

    let horizon: StellarSDK
    let accountId: String
    let recordCount: Int?
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<[StellarTransaction]> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         accountId: String,
         limit: Int? = FetchTransactionsOperation.defaultRecordCount,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.accountId = accountId
        self.recordCount = limit
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.transactions.getTransactions(forAccount: accountId,
                                             from: nil,
                                             order: .descending,
                                             limit: self.recordCount) { resp in
            switch resp {
            case .success(let response):
                let transactions = response.records
                let stellarTransactions: [StellarTransaction] = transactions.map { StellarTransaction($0) }
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
