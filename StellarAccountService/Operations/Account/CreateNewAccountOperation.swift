//
//  CreateAccountOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import Foundation

final class CreateNewAccountOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = AccountResponse
    typealias OutDataType = Bool

    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let accountId: String
    let amount: Decimal
    let userKeys: KeyPair
    let completion: BoolCompletion?
    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    var outData: Bool?
    var inData: AccountResponse?

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         accountId: String,
         amount: Decimal,
         userKeys: KeyPair,
         completion: BoolCompletion? = nil) {
        self.horizon = horizon
        self.api = api
        self.accountId = accountId
        self.amount = amount
        self.userKeys = userKeys
        self.completion = completion
    }

    override func main() {
        super.main()

        guard let accountResponse = self.inData else {
            self.finish()
            return
        }

        guard let destinationKeyPair = try? KeyPair(accountId: accountId) else {
            self.finish()
            return
        }

        let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: amount)

        do {
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [createAccount],
                                              memo: Memo.none,
                                              timeBounds: nil)

            try transaction.sign(keyPair: userKeys, network: api.network)

            try horizon.transactions.submitTransaction(transaction: transaction) { response -> Void in
                switch response {
                case .success(let value):
                    self.result = Result.success(value)
                case .failure(let error):
                    self.result = Result.failure(error)
                }

                self.finish()
            }
        } catch let error {
            self.result = Result.failure(error)
            self.finish()
        }
    }

    func finish() {
        state = .finished

        var value = false

        switch result {
        case .success: value = true
        case .failure: value = false
        }

        outData = value
        completion?(value)
    }
}
