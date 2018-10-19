//
//  StellarTransaction.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarTransaction {
    public let sourceAccount: String
    public let identifier: String
    public let ledger: Int
    public let createdAt: Date
    public let feePaid: Int
    public let memo: Memo?
    public let memoType: String?
    public let operationCount: Int
    public let sequenceNumber: String

    public let signatures: [String]
    public private(set) var operations: [StellarOperation] = []

    init(account: String,
         txId: String,
         ledger: Int,
         createdAt: Date,
         feePaid: Int,
         memo: Memo?,
         memoType: String?,
         operationCount: Int,
         sequence: String,
         signatures: [String]) {
        self.sourceAccount = account
        self.identifier = txId
        self.ledger = ledger
        self.createdAt = createdAt
        self.feePaid = feePaid
        self.memo = memo
        self.memoType = memoType
        self.operationCount = operationCount
        self.sequenceNumber = sequence
        self.signatures = signatures
    }

    func fetchOperations() {
        guard self.operations.count == 0 else { return }
    }
}
