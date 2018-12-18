//
//  StellarTransaction.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarTransaction: Codable {
    public let sourceAccount: String
    public let identifier: String
    public let ledger: Int
    public let createdAt: Date
    public let feePaid: Int
    public let memo: Memo?
    public let memoType: String?
    public let operationCount: Int
    public let sequenceNumber: String
    public let hash: String
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
        self.hash = response.transactionHash
        self.signatures = response.signatures
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case account = "source_account"
        case identifier = "id"
        case ledger
        case createdAt = "created_at"
        case fee = "fee_paid"
        case memo
        case memoType = "memo_type"
        case operationCount = "operation_count"
        case sequence = "source_account_sequence"
        case hash
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.sourceAccount = try container.decode(String.self, forKey: .account)
        self.ledger = try container.decode(Int.self, forKey: .ledger)
        self.feePaid = try container.decode(Int.self, forKey: .fee)

        // Implement later
        // self.memo = try container.decodeIfPresent(Memo.self, forKey: .memo)
        self.memo = nil

        self.memoType = try container.decodeIfPresent(String.self, forKey: .memoType)
        self.operationCount = try container.decode(Int.self, forKey: .operationCount)
        self.sequenceNumber = try container.decode(String.self, forKey: .sequence)
        self.hash = try container.decode(String.self, forKey: .hash)
        self.signatures = try container.decode([String].self, forKey: .signatures)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sourceAccount, forKey: .account)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.ledger, forKey: .ledger)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.feePaid, forKey: .fee)
        // try container.encode(self.memo, forKey: .memo)
        try container.encode(self.memoType, forKey: .memoType)
        try container.encode(self.operationCount, forKey: .operationCount)
        try container.encode(self.sequenceNumber, forKey: .sequence)
        try container.encode(self.hash, forKey: .hash)
        try container.encode(self.signatures, forKey: .signatures)
    }
}
