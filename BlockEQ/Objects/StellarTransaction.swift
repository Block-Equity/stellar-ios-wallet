//
//  StellarTransaction.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import stellarsdk

final class StellarTransaction {
    let sourceAccount: String
    let identifier: String
    let ledger: Int
    let createdAt: Date
    let feePaid: Int
    let memo: String?
    let memoType: String?
    let operationCount: Int
    let sequenceNumber: String

    let signatures: [String]
    var operations: [StellarOperation] = []

    init(account: String,
         txId: String,
         ledger: Int,
         createdAt: Date,
         feePaid: Int,
         memo: String?,
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

        FetchTransactionOperationsOperation.getOperations(transactionId: identifier, completion: { ops in
            self.operations = ops
            ops.forEach { $0.fetchEffects() }
        }, failure: { error in
            print(error)
        })
    }
}
