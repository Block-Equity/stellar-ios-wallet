//
//  StellarOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class StellarOperation {
    let identifier: String
    let createdAt: Date
    let operationType: String
    var effects: [StellarEffect] = []

    init(identifier: String, createdAt: Date, operationType: String) {
        self.identifier = identifier
        self.createdAt = createdAt
        self.operationType = operationType
    }

    func fetchEffects() {
        FetchOperationEffectsOperation.getOperations(operation: identifier, completion: { effects in
            self.effects = effects
        }, failure: { error in
            print(error)
        })
    }
}
