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

    init(_ response: TransactionResponse) {
        self.sourceAccount = response.sourceAccount
        self.identifier = response.id
        self.ledger = response.ledger
        self.createdAt = response.createdAt
        self.feePaid = response.feePaid
        self.memo = response.memo
        self.memoType = response.memoType
        self.operationCount = response.operationCount
        self.sequenceNumber = response.sourceAccountSequence
        self.signatures = response.signatures
    }
}
