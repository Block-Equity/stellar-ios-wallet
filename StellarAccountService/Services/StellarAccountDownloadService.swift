//
//  StellarAccountDownloadService.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-11-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

public final class StellarAccountDownloadService: StellarAccountDownloadServiceProtocol {

    var core: CoreService

    internal init(with core: CoreService) {
        self.core = core
    }

    internal lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1

        return queue
    }()

    func download() {
        let accountId = "GCXRMMINCZYBOJ3UT7CLHJOVZEEIEWU5YXBOP4ZCTESSVQ4SGJN27G3T"
//        let accountOp = FetchAccountDataOperation(horizon: core.sdk,
//                                                  account: accountId,
//                                                  completion: { _ in }, failure: { _ in })

//        var effectsCursor: String?

        var accountEffects: [StellarEffect] = []
        let queue = OperationQueue()

        let completion: FetchAccountEffectsOperation.SuccessCompletion = { effects, operation in
            accountEffects.append(contentsOf: effects)

            if let next = operation.next {
                print("fetching next page")
                queue.addOperation(next)
            } else {
                print("ALL DONE!")
                print("COUNT: \(accountEffects.count)")
            }
        }

        let effectsOp = FetchAccountEffectsOperation(horizon: core.sdk,
                                                     accountId: accountId,
                                                     completion: completion,
                                                     failure: { _ in },
                                                     recordCount: 200,
                                                     cursor: nil)

        queue.addOperation(effectsOp)
    }
}
