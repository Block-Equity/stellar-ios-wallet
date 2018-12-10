//
//  FetchOffersOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchOffersOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarAccountOffer]) -> Void

    static let defaultRecordCount: Int = 200

    let horizon: StellarSDK
    let address: StellarAddress
    let recordCount: Int?
    let completion: SuccessCompletion?
    let failure: ErrorCompletion?
    var result: Result<[StellarAccountOffer]> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         address: StellarAddress,
         recordCount: Int? = FetchOffersOperation.defaultRecordCount,
         completion: SuccessCompletion? = nil,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.address = address
        self.recordCount = recordCount
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        let acc = address.string
        horizon.offers.getOffers(forAccount: acc, cursor: nil, order: .descending, limit: recordCount) { response in
            switch response {
            case .success(let offerResponse):
                let offers = offerResponse.records.compactMap { StellarAccountOffer($0) }
                self.result = Result.success(offers)
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
