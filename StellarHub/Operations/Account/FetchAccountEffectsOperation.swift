//
//  FetchEffectsOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-20.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

final class FetchAccountEffectsOperation: AsyncOperation {
    typealias SuccessCompletion = ([StellarEffect], FetchAccountEffectsOperation) -> Void

    static let defaultRecordCount: Int = 200

    let horizon: StellarSDK
    let accountId: String
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    let recordCount: Int?
    let cursor: String?
    var result: Result<[StellarEffect]> = Result.failure(AsyncOperationError.responseUnset)
    var next: FetchAccountEffectsOperation?

    init(horizon: StellarSDK,
         accountId: String,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion? = nil,
         recordCount: Int? = FetchAccountEffectsOperation.defaultRecordCount,
         cursor: String? = nil) {
        self.horizon = horizon
        self.accountId = accountId
        self.completion = completion
        self.failure = failure
        self.recordCount = recordCount
        self.cursor = cursor
    }

    override func main() {
        super.main()

        horizon.effects.getEffects(forAccount: accountId,
                                   from: self.cursor,
                                   order: .descending,
                                   limit: recordCount) { resp in
            switch resp {
            case .success(let effectsResponse):
                self.setupNextRequest(response: effectsResponse)
                let effects = effectsResponse.records.map {
                    return StellarEffect($0)
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
            completion(response, self)
        case .failure(let error):
            failure?(error)
        }
    }
}

extension FetchAccountEffectsOperation: PageableOperation {
    typealias ResponseType = EffectResponse

    func setupNextRequest(response: PageResponse<EffectResponse>) {
        if let cursor = self.getCursor(for: response) {
            self.next = FetchAccountEffectsOperation(horizon: self.horizon,
                                                     accountId: self.accountId,
                                                     completion: self.completion,
                                                     failure: self.failure,
                                                     recordCount: self.recordCount,
                                                     cursor: cursor)
        }
    }
}
