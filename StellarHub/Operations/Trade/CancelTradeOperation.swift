//
//  CancelTradeOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

internal final class CancelTradeOperation: AsyncOperation, ChainableOperation {
    typealias InDataType = AccountResponse
    typealias OutDataType = Bool

    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let tradeData: StellarTradeOfferData
    let userKeys: KeyPair
    let completion: ServiceErrorCompletion

    var inData: AccountResponse?
    var outData: Bool?

    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         tradeData: StellarTradeOfferData,
         userKeys: KeyPair,
         completion: @escaping ServiceErrorCompletion) {
        self.horizon = horizon
        self.api = api
        self.tradeData = tradeData
        self.userKeys = userKeys
        self.completion = completion

        super.init()
    }

    override func main() {
        super.main()

        let buyAsset = tradeData.assetPair.buying.toRawAsset()
        let sellAsset = tradeData.assetPair.selling.toRawAsset()

        guard let accountResponse = self.inData, let offerId = tradeData.offerId else {
            self.finish()
            return
        }

        let manageOfferOperation = ManageOfferOperation(sourceAccount: userKeys,
                                                        selling: sellAsset,
                                                        buying: buyAsset,
                                                        amount: 0,
                                                        price: tradeData.price,
                                                        offerId: UInt64(offerId))

        do {
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [manageOfferOperation],
                                              memo: Memo.none,
                                              timeBounds: nil)

            try transaction.sign(keyPair: self.userKeys, network: api.network)

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
}
