//
//  FetchOrderBookOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchOrderBookOperation: AsyncOperation {
    typealias SuccessCompletion = (OrderbookResponse) -> Void

    let horizon: StellarSDK
    let assetPair: StellarAssetPair
    let recordCount: Int?
    let completion: SuccessCompletion?
    let failure: ErrorCompletion?
    var result: Result<OrderbookResponse> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         assetPair: StellarAssetPair,
         recordCount: Int?,
         completion: SuccessCompletion? = nil,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.assetPair = assetPair
        self.recordCount = recordCount
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.orderbooks.getOrderbook(sellingAssetType: assetPair.selling.assetType,
                                        sellingAssetCode: assetPair.selling.assetCode,
                                        sellingAssetIssuer: assetPair.selling.assetIssuer,
                                        buyingAssetType: assetPair.buying.assetType,
                                        buyingAssetCode: assetPair.buying.assetCode,
                                        buyingAssetIssuer: assetPair.buying.assetIssuer,
                                        limit: self.recordCount) { response in
            switch response {
            case .success(let orderBookResponse):
                self.result = Result.success(orderBookResponse)
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
            completion?(response)
        case .failure(let error):
            failure?(error)
        }
    }
}
