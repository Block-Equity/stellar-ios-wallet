//
//  StellarOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarOperation: Codable {
    public let identifier: String
    public let createdAt: Date
    public let operationType: OperationType
    public let transactionHash: String

    init(_ response: OperationResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.operationType = response.operationType
        self.transactionHash = response.transactionHash
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case identifier
        case createdAt
        case type
        case hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.transactionHash = try container.decode(String.self, forKey: .hash)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)

        let typeInt = try container.decode(Int32.self, forKey: .type)
        self.operationType = OperationType(rawValue: typeInt) ?? .bumpSequence
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.transactionHash, forKey: .hash)
        try container.encode(self.operationType.rawValue, forKey: .type)
    }
}
