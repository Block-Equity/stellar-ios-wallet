//
//  FetchEffectsOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchAccountEffectsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarEffect]) -> Void

    let horizon: StellarSDK
    let accountId: String
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<[StellarEffect]> = Result.failure(AsyncOperationError.responseUnset)

    init(horizon: StellarSDK,
         accountId: String,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion? = nil) {
        self.horizon = horizon
        self.accountId = accountId
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        horizon.effects.getEffects(forAccount: self.accountId, from: nil, order: .ascending, limit: 200) { response in
            switch response {
            case .success(let effectsResponse):
                let effects = effectsResponse.records.map {
                    return StellarEffect(response: $0)
                }

                self.result = Result.success(effects)
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
            completion(response)
        case .failure(let error):
            failure?(error)
        }
    }
}
