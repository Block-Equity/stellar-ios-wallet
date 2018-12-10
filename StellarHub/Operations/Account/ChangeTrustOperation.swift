//
//  ChangeTrustOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

internal final class ChangeAccountTrustOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = Void
    typealias OutDataType = Bool

    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let limit: Decimal?
    let userKeyPair: KeyPair
    let asset: StellarAsset
    let accountResponse: AccountResponse
    let completion: ServiceErrorCompletion

    var inData: Void?
    var outData: Bool?

    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         asset: StellarAsset,
         limit: Decimal?,
         accountResponse: AccountResponse,
         userKeyPair: KeyPair,
         completion: @escaping ServiceErrorCompletion) {
        self.horizon = horizon
        self.api = api
        self.userKeyPair = userKeyPair
        self.asset = asset
        self.limit = limit
        self.accountResponse = accountResponse
        self.completion = completion

        super.init()
    }

    override func main() {
        super.main()

        let asset = self.asset.toRawAsset()
        let changeTrustOperation = ChangeTrustOperation(sourceAccount: userKeyPair, asset: asset, limit: limit)

        do {
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [changeTrustOperation],
                                              memo: Memo.none,
                                              timeBounds: nil)

            try transaction.sign(keyPair: userKeyPair, network: api.network)

            try horizon.transactions.submitTransaction(transaction: transaction) { response -> Void in
                switch response {
                case .success(let value):
                    self.result = Result.success(value)
                case .failure(let error):
                    self.result = Result.failure(error)
                }

                self.finish()
                return
            }
        } catch let error {
            self.result = Result.failure(error)
            self.finish()
        }
    }

    func finish() {
        state = .finished

        switch result {
        case .success:
            outData = true
            completion(nil)
        case .failure(let error):
            let wrappedError = FrameworkError(error: error)
            completion(wrappedError)
        }
    }
}
