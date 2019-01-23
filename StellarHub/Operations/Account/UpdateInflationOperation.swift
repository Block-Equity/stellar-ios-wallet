//
//  UpdateInflationOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

internal final class UpdateInflationOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = AccountResponse
    typealias OutDataType = Bool

    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let address: StellarAddress?
    let userKeys: KeyPair
    let completion: ServiceErrorCompletion

    var inData: AccountResponse?
    var outData: Bool?

    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    private var inflationKeyPair: KeyPair? {
        guard let addressString = address?.string else { return nil }
        return try? KeyPair(accountId: addressString)
    }

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         address: StellarAddress?,
         userKeys: KeyPair,
         completion: @escaping ServiceErrorCompletion) {
        self.horizon = horizon
        self.api = api
        self.address = address
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

        let inflationKeyPair = self.inflationKeyPair

        do {
            let setOptionsOperation = try SetOptionsOperation(sourceAccount: self.userKeys,
                                                              inflationDestination: inflationKeyPair,
                                                              clearFlags: nil,
                                                              setFlags: nil,
                                                              masterKeyWeight: nil,
                                                              lowThreshold: nil,
                                                              mediumThreshold: nil,
                                                              highThreshold: nil,
                                                              homeDomain: nil,
                                                              signer: nil,
                                                              signerWeight: nil)

            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [setOptionsOperation],
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
            result = Result.failure(error)
            finish()
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
