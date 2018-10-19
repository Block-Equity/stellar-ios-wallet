//
//  FetchAccountOperationsOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchAccountOperationsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarOperation]) -> Void

    let horizon: StellarSDK
    let accountId: String
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<[StellarOperation]> = Result.failure(AsyncOperationError.responseUnset)

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

        horizon.operations.getOperations(forAccount: self.accountId) { operationResponse in
            switch operationResponse {
            case .success(let operationResponse):
                let operations = operationResponse.records.map { operation in
                    return StellarOperation(identifier: operation.id,
                                            createdAt: operation.createdAt,
                                            operationType: operation.operationType)
                }

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
