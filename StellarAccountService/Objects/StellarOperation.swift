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

    init(_ response: OperationResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.operationType = response.operationType
    }
}
