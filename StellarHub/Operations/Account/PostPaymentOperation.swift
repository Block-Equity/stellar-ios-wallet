//
//  PostPaymentOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class PostPaymentOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = AccountResponse
    typealias OutDataType = Bool

    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let data: StellarPaymentData
    let userKeyPair: KeyPair
    let completion: ServiceErrorCompletion

    var inData: AccountResponse?
    var outData: Bool?

    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         data: StellarPaymentData,
         userKeyPair: KeyPair,
         completion: @escaping ServiceErrorCompletion) {
        self.horizon = horizon
        self.api = api
        self.userKeyPair = userKeyPair
        self.data = data
        self.completion = completion

        super.init()
    }

    override func main() {
        super.main()

        guard let accountResponse = self.inData, let destKeyPair = data.destinationKeyPair else {
            finish()
            return
        }

        do {
            let paymentOperation = PaymentOperation(sourceAccount: userKeyPair,
                                                    destination: destKeyPair,
                                                    asset: data.asset.toRawAsset(),
                                                    amount: data.amount)

            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [paymentOperation],
                                              memo: createMemo(from: data.memo),
                                              timeBounds: nil)

            try transaction.sign(keyPair: userKeyPair, network: api.network)

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
            outData = false

            completion(wrappedError)
        }
    }

    private func createMemo(from memoId: String?) -> Memo {
        var memo = Memo.none

        if let memoId = memoId, !memoId.isEmpty {
            if let memoNumber = UInt64(memoId) {
                memo = Memo.id(memoNumber)
            } else {
                memo = Memo.text(memoId)
            }
        } else {
            memo = Memo.none
        }

        return memo
    }
}
