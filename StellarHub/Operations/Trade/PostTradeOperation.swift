//
//  PostTradeOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

internal final class PostTradeOperation: AsyncOperation, ChainableOperation {
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

        guard let accountResponse = self.inData else {
            finish()
            return
        }

        let finalNumerator = tradeData.type == .market ? tradeData.numerator * Decimal(0.999) : tradeData.numerator
        let price = scaledPrice(price: (finalNumerator, tradeData.denominator))
        let buyAsset = tradeData.assetPair.buying.toRawAsset()
        let sellAsset = tradeData.assetPair.selling.toRawAsset()

        let manageOfferOperation = ManageOfferOperation(sourceAccount: userKeys,
                                                        selling: sellAsset,
                                                        buying: buyAsset,
                                                        amount: tradeData.denominator,
                                                        price: price,
                                                        offerId: 0)

        do {
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [manageOfferOperation],
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
            outData = false

            completion(wrappedError)
        }
    }

    internal func scaledPrice(price: (numerator: Decimal, denominator: Decimal)) -> Price {
        var num: Decimal = price.numerator
        var den: Decimal = price.denominator

        let decimalInt32Max = Decimal(Int32.max)

        let maxPlaces = Int(max(price.numerator.exponent.magnitude, price.denominator.exponent.magnitude))
        for currentPlaces in 0...maxPlaces {
            let scale: Decimal = pow(10.0, maxPlaces - currentPlaces)

            let scaledNumerator = price.numerator * scale
            let scaledDenominator = price.denominator * scale

            if scaledNumerator <= decimalInt32Max && scaledDenominator <= decimalInt32Max {
                num = scaledNumerator
                den = scaledDenominator
                break
            }
        }

        return Price(numerator: NSDecimalNumber(decimal: num).int32Value,
                     denominator: NSDecimalNumber(decimal: den).int32Value)
    }
}
