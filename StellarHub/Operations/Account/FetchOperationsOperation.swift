//
//  FetchAccountOperationsOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchAccountOperationsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarOperation]) -> Void

    static let defaultRecordCount: Int = 200

    let horizon: StellarSDK
    let accountId: String
    let recordCount: Int?
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<[StellarOperation]> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         accountId: String,
         recordCount: Int = FetchAccountOperationsOperation.defaultRecordCount,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.accountId = accountId
        self.recordCount = recordCount
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.operations.getOperations(forAccount: accountId,
                                         from: nil,
                                         order: .descending,
                                         limit: recordCount) { operationResponse in
            switch operationResponse {
            case .success(let operationResponse):
                let operations = operationResponse.records.map { StellarOperation($0) }
                self.result = Result.success(operations)
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
