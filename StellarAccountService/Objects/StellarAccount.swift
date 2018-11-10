//
//  StellarAccount.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarAccount {
    public internal(set) var accountId = ""
    public internal(set) var inflationDestination: String?
    public internal(set) var totalTrustlines: Int = 0
    public internal(set) var totalOffers: Int = 0
    public internal(set) var totalSigners: Int = 0
    public internal(set) var totalBaseReserve: Int = 1
    public internal(set) var isStub: Bool = false
    public internal(set) var assets: [StellarAsset] = []
    public internal(set) var mappedEffects: [String: StellarEffect] = [:]
    public internal(set) var mappedTransactions: [String: StellarTransaction] = [:]
    public internal(set) var mappedOperations: [String: StellarOperation] = [:]
    public internal(set) var mappedOffers: [Int: StellarAccountOffer] = [:]
    internal var rawResponse: AccountResponse?

    internal weak var sendResponseDelegate: SendAmountResponseDelegate?
    internal weak var manageAssetResponseDelegate: ManageAssetResponseDelegate?

    public var address: StellarAddress {
        return StellarAddress(accountId)!
    }

    public var inflationAddress: StellarAddress? {
        return StellarAddress(inflationDestination)
    }

    public var effects: [StellarEffect] {
        return Array(mappedEffects.values)
    }

    public var transactions: [StellarTransaction] {
        return Array(mappedTransactions.values)
    }

    public var operations: [StellarOperation] {
        return Array(mappedOperations.values)
    }

    public var tradeOffers: [StellarAccountOffer] {
        return Array(mappedOffers.values)
    }

    public var indexedAssets: [String: StellarAsset] {
        return assets.reduce(into: [:], { list, asset in
            list[asset.shortCode] = asset
        })
    }

    public init(_ response: AccountResponse) {
        self.accountId = response.accountId
        self.inflationDestination = response.inflationDestination
        self.totalTrustlines = response.balances.count - 1
        self.totalSigners = response.signers.count
        self.totalOffers = Int(response.subentryCount) - self.totalTrustlines
        self.assets = response.balances
            .map { return StellarAsset(response: $0) }
            .sorted(by: { first, second -> Bool in
                first.isNative != second.isNative
            })
    }

    // Creates a stub account that can be used, but has not yet been fetched from the Horizon API
    internal init(accountId: String) {
        self.accountId = accountId
        self.isStub = true
        self.assets.insert(StellarAsset.lumens, at: 0)
    }

    internal func update(withRaw response: AccountResponse) {
        let account = StellarAccount(response)
        self.rawResponse = response
        self.accountId = account.accountId
        self.inflationDestination = account.inflationDestination
        self.totalTrustlines = account.totalTrustlines
        self.totalSigners = account.totalSigners
        self.totalOffers = account.totalOffers
        self.assets = account.assets
        self.isStub = false
    }

    public var baseReserve: Decimal {
        return Decimal(totalBaseReserve) * 0.5
    }

    public var trustlines: Decimal {
        return Decimal(totalTrustlines) * 0.5
    }

    public var offers: Decimal {
        return Decimal(totalOffers) * 0.5
    }

    public var signers: Decimal {
        return Decimal(totalSigners) * 0.5
    }

    public var minBalance: Decimal {
        return baseReserve + trustlines + offers + signers
    }

    public var availableBalance: Decimal {
        var totalBalance = Decimal(0.00)
        for asset in assets where asset.assetType == AssetTypeAsString.NATIVE {
            if let assetBalance = Decimal(string: asset.balance) {
                totalBalance = assetBalance
            }
        }

        let calculatedBalance = totalBalance - minBalance

        if calculatedBalance >= 0.0 {
            return calculatedBalance
        }
        return totalBalance
    }
}

extension StellarAccount: Hashable {
    public static func == (lhs: StellarAccount, rhs: StellarAccount) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(accountId)
        hasher.combine(inflationDestination)
        hasher.combine(baseReserve)
        hasher.combine(trustlines)
        hasher.combine(offers)
        hasher.combine(signers)

        transactions.forEach { hasher.combine($0.hash) }
        effects.forEach { hasher.combine($0.operationId) }
        operations.forEach { hasher.combine($0.transactionHash) }
        assets.forEach { hasher.combine($0.assetCode) }
    }
}
