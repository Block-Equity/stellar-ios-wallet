//
//  CreatePersonalTokenOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

internal final class CreatePersonalTokenOperation: AsyncOperation {
    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let userKeys: KeyPair
    let completion: BoolCompletion?
    let assetCode: String

    var inData: AccountResponse?
    var outData: Bool?

    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         assetCode: String,
         userKeys: KeyPair,
         completion: BoolCompletion? = nil) {
        self.horizon = horizon
        self.api = api
        self.assetCode = assetCode
        self.userKeys = userKeys
        self.completion = completion

        super.init()
    }

    override func main() {
        super.main()

        guard let accountResponse = self.inData else {
            finish()
            return
        }

        do {
            let manageDataOperation = ManageDataOperation(sourceAccount: self.userKeys,
                                                          name: "PersonalAccount",
                                                          data: assetCode.data(using: .utf8))

            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [manageDataOperation],
                                              memo: Memo.none,
                                              timeBounds: nil)

            try transaction.sign(keyPair: self.userKeys, network: api.network)

            try horizon.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
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
            return
        }
    }

    func finish() {
        state = .finished

        var created: Bool = false

        switch result {
        case .success: created = true
        case .failure: created = false
        }

        outData = created
        completion?(created)
    }
}
