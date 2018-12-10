//
//  FetchAccountDataOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchAccountDataOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = Bool
    typealias OutDataType = AccountResponse

    typealias SuccessCompletion = (AccountResponse) -> Void

    let horizon: StellarSDK
    let accountId: String
    var completion: SuccessCompletion?
    var failure: ServiceErrorCompletion?
    var result: Result<AccountResponse> = Result.failure(AsyncOperationError.responseUnset)

    var outData: AccountResponse?
    var inData: Bool?

    init(horizon: StellarSDK,
         account: String,
         completion: SuccessCompletion? = nil,
         failure: ServiceErrorCompletion? = nil) {
        self.horizon = horizon
        self.accountId = account
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.accounts.getAccountDetails(accountId: accountId) { response -> Void in
            switch response {
            case .success(let response):
                self.result = Result.success(response)
            case .failure(let error):
                self.result = Result.failure(error)
            }

            self.finish()
        }
    }

    func finish() {
        switch result {
        case .success(let response):
            outData = response
            completion?(response)
        case .failure(let error):
            let wrappedError = FrameworkError(error: error)
            outData = nil

            failure?(wrappedError)
        }

        state = .finished
    }
}
