//
//  StellarAccount.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

extension StellarAccount {
    public struct UpdateOptions: OptionSet {
        public let rawValue: Int
        public static let inactive = UpdateOptions(rawValue: 1 << 0)
        public static let account = UpdateOptions(rawValue: 1 << 1)
        public static let transactions = UpdateOptions(rawValue: 1 << 2)
        public static let effects = UpdateOptions(rawValue: 1 << 3)
        public static let operations = UpdateOptions(rawValue: 1 << 4)
        public static let tradeOffers = UpdateOptions(rawValue: 1 << 5)

        public static let all: UpdateOptions = [.account, .transactions, .effects, .operations]
        public static let none: UpdateOptions = []

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

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

    internal weak var service: StellarAccountService?
    internal weak var inflationResponseDelegate: SetInflationResponseDelegate?
    internal weak var sendResponseDelegate: SendAmountResponseDelegate?
    internal weak var manageAssetResponseDelegate: ManageAssetResponseDelegate?

    internal var accountQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        return queue
    }

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

    public init(response: AccountResponse) {
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
        let account = StellarAccount(response: response)
        self.rawResponse = response
        self.accountId = account.accountId
        self.inflationDestination = account.inflationDestination
        self.totalTrustlines = account.totalTrustlines
        self.totalSigners = account.totalSigners
        self.totalOffers = account.totalOffers
        self.assets = account.assets
        self.isStub = false
    }

    public var baseReserve: Double {
        return Double(totalBaseReserve) * 0.5
    }

    public var trustlines: Double {
        return Double(totalTrustlines) * 0.5
    }

    public var offers: Double {
        return Double(totalOffers) * 0.5
    }

    public var signers: Double {
        return Double(totalSigners) * 0.5
    }

    public var minBalance: Double {
        return baseReserve + trustlines + offers + signers
    }

    public var availableBalance: Double {
        var totalBalance = 0.00
        for asset in assets where asset.assetType == AssetTypeAsString.NATIVE {
            if let assetBalance = Double(asset.balance) {
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
