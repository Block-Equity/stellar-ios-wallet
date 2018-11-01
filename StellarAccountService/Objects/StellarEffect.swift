//
//  StellarEffect.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarEffect: Codable {
    public let identifier: String
    public let pagingToken: String
    public let type: EffectType
    public let createdAt: String
    public private(set) var amount = ""
    public private(set) var soldAmount = ""
    public private(set) var boughtAmount = ""
    public private(set) var asset: StellarAsset = StellarAsset.lumens
    public private(set) var assetPair = StellarAssetPair(buying: StellarAsset.lumens, selling: StellarAsset.lumens)

    public var operationId: String {
        let parts = self.pagingToken.split(separator: "-")
        return String(parts.first ?? "")
    }

    init(_ response: EffectResponse) {
        self.identifier = response.id
        self.createdAt = response.createdAt
        self.type = response.effectType
        self.pagingToken = response.pagingToken

        switch response.effectType {
        case .accountCreated: self.setUpdatedEffect(with: response)
        case .accountDebited: self.setDebitedEffect(with: response)
        case .accountCredited: self.setCreditedEffect(with: response)
        case .tradeEffect: self.setTradeEffect(with: response)
        case .accountInflationDestinationUpdated: self.setInflationEffect(with: response)
        default: break
        }
    }

    // MARK: - Helpers
    private func setUpdatedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreatedEffectResponse else {
            return
        }

        amount = updatedEffect.startingBalance
    }

    private func setDebitedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountDebitedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
    }

    private func setCreditedEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? AccountCreditedEffectResponse else {
            return
        }

        amount = updatedEffect.amount
        asset = StellarAsset(assetType: updatedEffect.assetType,
                             assetCode: updatedEffect.assetCode,
                             assetIssuer: updatedEffect.assetIssuer,
                             balance: "")
    }

    private func setTradeEffect(with effectResponse: EffectResponse) {
        guard let updatedEffect = effectResponse as? TradeEffectResponse else {
            return
        }

        let selling = StellarAsset(assetType: updatedEffect.soldAssetType,
                                         assetCode: updatedEffect.soldAssetCode,
                                         assetIssuer: updatedEffect.soldAssetIssuer,
                                         balance: "")

        let buying = StellarAsset(assetType: updatedEffect.boughtAssetType,
                                        assetCode: updatedEffect.boughtAssetCode,
                                        assetIssuer: updatedEffect.boughtAssetIssuer,
                                        balance: "")

        self.assetPair = StellarAssetPair(buying: buying, selling: selling)

        boughtAmount = updatedEffect.boughtAmount
        soldAmount = updatedEffect.soldAmount
    }

    private func setInflationEffect(with effectResponse: EffectResponse) {
    }

    public func isBought(asset: StellarAsset) -> Bool {
        return asset == self.assetPair.buying
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case identifier
        case pagingToken
        case type
        case createdAt
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.pagingToken, forKey: .pagingToken)
        try container.encode(self.type.rawValue, forKey: .type)
        try container.encode(self.createdAt, forKey: .createdAt)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.pagingToken = try container.decode(String.self, forKey: .pagingToken)

        let typeInt = try container.decode(Int.self, forKey: .type)
        self.type = EffectType(rawValue: typeInt) ?? .sequenceBumpedEffect
    }
}
