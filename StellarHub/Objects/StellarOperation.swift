//
//  StellarOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarOperation {
    public typealias PaymentData = (asset: StellarAsset, destination: String)
    public typealias ManageData = (pair: StellarAssetPair, amount: String, price: String, offerId: Int)
    public typealias CreateData = (account: String, balance: Decimal)
    public typealias OptionsData = (inflationDest: String?, homeDomain: String?, signerKey: String?, signerWeight: Int?)
    public typealias ChangeTrustData = (asset: StellarAsset, trustee: String, trustor: String)
    public typealias AllowTrustData = (asset: StellarAsset, trustee: String, trustor: String, allow: Bool)
    public typealias MergeData = (from: String, into: String)

    public let identifier: String
    public let createdAt: Date
    public let operationType: OperationType
    public let transactionHash: String

    public var paymentData: PaymentData?
    public var manageData: ManageData?
    public var createData: CreateData?
    public var optionsData: OptionsData?
    public var changeTrustData: ChangeTrustData?
    public var allowTrustData: AllowTrustData?
    public var mergeData: MergeData?

    //swiftlint:disable function_body_length
    init(_ response: OperationResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.operationType = response.operationType
        self.transactionHash = response.transactionHash

        if let paymentResponse = response as? PaymentOperationResponse {
            paymentData = (destination: paymentResponse.to,
                           asset: StellarAsset(assetType: paymentResponse.assetType,
                                               assetCode: paymentResponse.assetCode,
                                               assetIssuer: paymentResponse.assetIssuer,
                                               balance: paymentResponse.amount))
        } else if let manageOfferResponse = response as? ManageOfferOperationResponse {
            let sellAsset = StellarAsset(assetType: manageOfferResponse.sellingAssetType,
                                         assetCode: manageOfferResponse.sellingAssetCode,
                                         assetIssuer: manageOfferResponse.sellingAssetIssuer,
                                         balance: "")

            let buyAsset = StellarAsset(assetType: manageOfferResponse.buyingAssetType,
                                        assetCode: manageOfferResponse.buyingAssetCode,
                                        assetIssuer: manageOfferResponse.buyingAssetIssuer,
                                        balance: "")

            manageData = (price: manageOfferResponse.price,
                          amount: manageOfferResponse.amount,
                          pair: StellarAssetPair(buying: buyAsset, selling: sellAsset),
                          offerId: manageOfferResponse.offerId)

        } else if let trustResponse = response as? AllowTrustOperationResponse {
            allowTrustData = (asset: StellarAsset(assetType: trustResponse.assetType,
                                                  assetCode: trustResponse.assetCode,
                                                  assetIssuer: trustResponse.assetIssuer,
                                                  balance: ""),
                              trustee: trustResponse.trustee,
                              trustor: trustResponse.trustor,
                              allow: trustResponse.authorize)
        } else if let trustResponse = response as? ChangeTrustOperationResponse {
            changeTrustData = (asset: StellarAsset(assetType: trustResponse.assetType,
                                                   assetCode: trustResponse.assetCode,
                                                   assetIssuer: trustResponse.assetIssuer,
                                                   balance: trustResponse.limit ?? ""),
                               trustee: trustResponse.trustee,
                               trustor: trustResponse.trustor)
        } else if let optionsResponse = response as? SetOptionsOperationResponse {
            optionsData = (inflationDest: optionsResponse.inflationDestination,
                           homeDomain: optionsResponse.homeDomain,
                           signerKey: optionsResponse.signerKey,
                           signerWeight: optionsResponse.signerWeight)
        } else if let createdResponse = response as? AccountCreatedOperationResponse {
            createData = (account: createdResponse.account, balance: createdResponse.startingBalance)
        } else if let mergeResponse = response as? AccountMergeOperationResponse {
            mergeData = (from: mergeResponse.account, into: mergeResponse.into)
        }
    }
    //swiftlint:enable function_body_length
}

// MARK: - Codable
extension StellarOperation: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case createdAt = "created_at"
        case type = "type_i"
        case hash = "transaction_hash"
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
