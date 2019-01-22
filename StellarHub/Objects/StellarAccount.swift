//
//  StellarAccount.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarAccount {
    public static let stub = StellarAccount(accountId: "")

    public internal(set) var accountId = ""
    public internal(set) var inflationDestination: String?

    public let totalBaseAmount: Int = 2
    public internal(set) var totalTrustlines: Int = 0
    public internal(set) var additionalSigners: Int = 0
    public internal(set) var totalDataEntries: Int = 0
    public internal(set) var totalSubentries: Int = 0

    public internal(set) var assets: [StellarAsset] = []
    public internal(set) var mappedEffects: [String: StellarEffect] = [:]
    public internal(set) var mappedTransactions: [String: StellarTransaction] = [:]
    public internal(set) var mappedOperations: [String: StellarOperation] = [:]
    public internal(set) var mappedOffers: [Int: StellarAccountOffer] = [:]
    public internal(set) var outstandingTradeAmounts: [StellarAsset: Decimal] = [:]

    internal var rawResponse: AccountResponse?

    // See https://www.stellar.org/developers/guides/concepts/ledger.html#ledger-entries
    // Offers are computed as the number of subentries minus trustlines, minus data entries (not signers, base amount)
    public var totalOffers: Int {
        return self.totalSubentries - self.totalTrustlines - self.totalDataEntries
    }

    public var isStub: Bool {
        return rawResponse == nil
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

    public var indexedAssets: [String: StellarAsset] {
        return assets.reduce(into: [:], { list, asset in
            list[asset.shortCode] = asset
        })
    }

    public init(_ response: AccountResponse) {
        self.accountId = response.accountId
        self.inflationDestination = response.inflationDestination

        self.totalTrustlines = response.balances.count - 1
        self.additionalSigners = response.signers.count - 1
        self.totalDataEntries = response.data.count
        self.totalSubentries = Int(response.subentryCount)

        self.assets = response.balances
            .map { return StellarAsset(response: $0) }
            .sorted(by: { first, second -> Bool in
                first.isNative != second.isNative
            })
    }

    // Creates a stub account that can be used, but has not yet been fetched from the Horizon API
    internal init(accountId: String) {
        self.accountId = accountId
        self.assets.insert(StellarAsset.lumens, at: 0)
    }

    internal func update(withRaw response: AccountResponse) {
        let account = StellarAccount(response)

        rawResponse = response
        accountId = account.accountId
        inflationDestination = account.inflationDestination
        totalTrustlines = account.totalTrustlines
        additionalSigners = account.additionalSigners
        totalDataEntries = account.totalDataEntries
        totalSubentries = account.totalSubentries
        assets = account.assets
    }

    public var baseReserve: Decimal {
        return 0.5
    }

    public var baseFee: Decimal {
        return 0.00001
    }

    public var baseAmount: Decimal {
        return Decimal(totalBaseAmount) * baseReserve
    }

    public var trustlines: Decimal {
        return Decimal(totalTrustlines) * baseReserve
    }

    public var offers: Decimal {
        return Decimal(totalOffers) * baseReserve
    }

    public var dataEntries: Decimal {
        return Decimal(totalDataEntries) * baseReserve
    }

    public var signers: Decimal {
        return Decimal(additionalSigners) * baseReserve
    }

    public var minBalance: Decimal {
        let subentryBalance = Decimal(totalBaseAmount + totalSubentries) * baseReserve
        return subentryBalance
    }

    public var newEntryMinBalance: Decimal {
        return minBalance + baseReserve
    }

    public var hasRequiredNativeBalanceForNewEntry: Bool {
        return availableBalance(for: nativeAsset) - baseReserve > 0
    }

    public var hasRequiredNativeBalanceForTrade: Bool {
        return availableTradeBalance(for: nativeAsset) > 0
    }

    public var hasRequiredNativeBalanceForSend: Bool {
        return availableSendBalance(for: nativeAsset) > 0
    }

    /**
     Returns the native asset of the network for this account.
     */
    var nativeAsset: StellarAsset {
        guard let lumens = assets.first(where: { $0.assetType == AssetTypeAsString.NATIVE }) else {
            return StellarAsset.lumens
        }

        return lumens
    }

    /**
     Returns the amount of Lumens available on the account, less required minimum XLM balance.

     - Note: This amount does not consider amounts locked up in trades.
     */
    public var availableNativeBalance: Decimal {
        let totalBalance = Decimal(string: nativeAsset.balance) ?? Decimal(0)
        let calculatedBalance = totalBalance - minBalance
        return calculatedBalance >= 0.0 ? calculatedBalance : Decimal(0)
    }

    /**
     Returns the unmodified balance for the input asset.

     - Parameter asset: The balance of the requested asset.
     - Returns: A decimal amount representing that asset's balance.
     */
    public func totalBalance(for asset: StellarAsset) -> Decimal {
        return Decimal(string: asset.balance) ?? Decimal(0.00)
    }

    /**
     Returns the computed available balance for an asset, less any amount of that asset offered in trades.

     - Parameter asset: The balance of the requested asset.
     - Returns: A balance amount if there is a trustline to the asset with a positive balance, 0 otherwise.
    */
    public func availableBalance(for asset: StellarAsset, subtractTradeAmounts: Bool = true) -> Decimal {
        var balance: Decimal = 0

        guard let requestedAsset = assets.first(where: { $0 == asset }) else {
            return balance
        }

        if requestedAsset.isNative {
            balance = availableNativeBalance
        } else {
            balance = Decimal(string: requestedAsset.balance) ?? 0
        }

        let outstandingTradeAmount = outstandingTradeAmounts[asset] ?? 0
        return subtractTradeAmounts ? balance - outstandingTradeAmount : balance
    }

    /**
     This method computes the allowed amount of an asset to trade.

     - Parameter asset: The asset to calculate the trade balance for.
     - Returns: The amount the user is eligible to post for trade.
     - Note: If the requested asset is native, the returned amount incorporates the additional entry to the user's
     minimum balance (0.5 XLM)
     */
    public func availableTradeBalance(for asset: StellarAsset) -> Decimal {
        let availableBalance = self.availableBalance(for: asset)

        if asset.isNative {
            let availableTotal = availableBalance - baseFee - baseReserve
            return availableTotal > 0 ? availableTotal : 0
        } else {
            return availableBalance
        }
    }

    /**
     This method computes the allowed amount of a given asset to send.

     - Parameter asset: The asset to calculate the send balance for.
     - Returns: The amount the user is eligible to send.
     */
    public func availableSendBalance(for asset: StellarAsset) -> Decimal {
        let availableBalance = self.availableBalance(for: asset)

        if asset.isNative {
            let availableTotal = availableBalance - baseFee
            return availableTotal > 0 ? availableTotal : 0
        } else {
            return availableBalance
        }
    }
}

extension StellarAccount: Hashable {
    public static func == (lhs: StellarAccount, rhs: StellarAccount) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(accountId)
        hasher.combine(inflationDestination)
        hasher.combine(totalSubentries)

        transactions.forEach { hasher.combine($0.hash) }
        effects.forEach { hasher.combine($0.operationId) }
        operations.forEach { hasher.combine($0.transactionHash) }
        assets.forEach { hasher.combine($0.assetCode) }
    }
}
