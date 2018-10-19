//
//  StellarOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarOperation {
    public let identifier: String
    public let createdAt: Date
    public let operationType: OperationType
    public internal(set) var effects: [StellarEffect] = []

    init(response: OperationResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.operationType = response.operationType
    }

    init(identifier: String, createdAt: Date, operationType: OperationType) {
        self.identifier = identifier
        self.createdAt = createdAt
        self.operationType = operationType
    }
}
