//
//  StellarAsset.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarAsset {
    public let balance: String
    public let assetType: String
    public let assetCode: String?
    public let assetIssuer: String?

    public static var lumens: StellarAsset {
        return StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "")
    }

    public init(assetType: String, assetCode: String?, assetIssuer: String?, balance: String) {
        self.assetType = assetType
        self.assetCode = assetCode
        self.assetIssuer = assetIssuer
        self.balance = balance
    }

    public init(assetCode: String, issuer: String) {
        self.assetCode = assetCode
        self.assetIssuer = issuer
        self.balance = "0.0"
        self.assetType = AssetTypeAsString.CREDIT_ALPHANUM4
    }

    init(response: AccountBalanceResponse) {
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.balance = response.balance
    }

    init(_ response: OfferAssetResponse) {
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.balance = "0.0"
    }

    internal func toRawAsset() -> Asset {
        var type: Int32
        if let code = self.assetCode, code.count >= 5, code.count <= 12 {
            type = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        } else if let code = self.assetCode, code.count >= 1, code.count <= 4 {
            type = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
        } else {
            type = AssetType.ASSET_TYPE_NATIVE
        }

        if let issuer = self.assetIssuer {
            let issuerKeyPair = try? KeyPair(accountId: issuer)
            return Asset(type: type, code: self.assetCode, issuer: issuerKeyPair)!
        }

        return Asset(type: type, code: self.assetCode, issuer: nil)!
    }

    public var shortCode: String {
        if assetType == AssetTypeAsString.NATIVE {
            return "XLM"
        }

        if let code = assetCode {
            return code
        }

        return ""
    }

    public var isNative: Bool {
        if assetType == AssetTypeAsString.NATIVE {
            return true
        }

        return false
    }

    public var hasZeroBalance: Bool {
        if let balance = Decimal(string: balance) {
            return balance.isZero
        }

        return true
    }
}

extension StellarAsset: Equatable {
    public static func == (lhs: StellarAsset, rhs: StellarAsset) -> Bool {
        return lhs.assetType == rhs.assetType && lhs.assetCode == rhs.assetCode && lhs.assetIssuer == rhs.assetIssuer
    }
}

extension StellarAsset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.shortCode)
    }
}
