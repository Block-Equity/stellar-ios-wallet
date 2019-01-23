//
//  Protocols.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

// MARK: - Core Services
protocol CoreServiceProtocol {
    var sdk: StellarSDK { get }
    var api: StellarConfig.HorizonAPI { get }
    var services: [Subservice] { get }
    var secretManager: SecretManagerProtocol? { get }
    var walletKeyPair: KeyPair? { get }
}

protocol Subservice {
    var core: CoreServiceProtocol { get }
    func reset()
}

// MARK: - AccountUpdateService
protocol AccountUpdateServiceProtocol: AnyObject, Subservice {
    var account: StellarAccount? { get }
    var subscribers: MulticastDelegate<AccountUpdateServiceDelegate> { get set }
}

public protocol AccountUpdateServiceDelegate: AnyObject {
    func firstAccountUpdate(_ service: AccountUpdateService, account: StellarAccount)
    func accountUpdated(_ service: AccountUpdateService,
                        account: StellarAccount,
                        options: AccountUpdateService.UpdateOptions)
}

// MARK: - AccountManagementService
protocol AccountManagementServiceProtocol: AnyObject, Subservice {
    var subscribers: MulticastDelegate<AccountManagementServiceDelegate> { get set }
    var state: AccountManagementService.AccountState { get }
    var secretManager: SecretManager? { get set }
    var account: StellarAccount? { get set }
}

public protocol AccountManagementServiceDelegate: AnyObject {
    func accountSwitched(_ service: AccountManagementService, account: StellarAccount)
}

public protocol AccountUpdatable: AnyObject {
    func updated(account: StellarAccount)
}

public protocol SendAmountResponseDelegate: AnyObject {
    func sentAmount(destination: StellarAddress)
    func failed(error: FrameworkError)
}

public protocol SetInflationResponseDelegate: AnyObject {
    func setInflation(destination: StellarAddress)
    func clearInflation()
    func inflationFailed(error: FrameworkError)
}

public protocol ManageAssetResponseDelegate: AnyObject {
    func added(asset: StellarAsset, account: StellarAccount)
    func removed(asset: StellarAsset, account: StellarAccount)
    func manageFailed(error: FrameworkError)
}

// MARK: - TradeService
protocol TradeServiceProtocol: AnyObject, Subservice {
    var tradeQueue: OperationQueue { get }
}

public protocol TradeResponseDelegate: AnyObject {
    func cancelled(offerId: Int, trade: StellarTradeOfferData)
    func posted(trade: StellarTradeOfferData)
    func cancellationFailed(error: FrameworkError)
    func postingFailed(error: FrameworkError)
}

public protocol OfferResponseDelegate: AnyObject {
    func updated(orders: StellarOrderbook)
    func updated(offers: [StellarAccountOffer])
}

// MARK: - IndexingService
protocol IndexingServiceProtocol: Subservice {
    func updateIndex()
    func rebuildIndex()
    func reset()
    func pause()
    func resume()
    func relatedObject<In: IndexableStellarObject, Out: IndexableStellarObject>(startingAt object: In) -> Out?
}

public protocol IndexingServiceDelegate: AnyObject {
    func finishedIndexing(_ service: IndexingService)
    func errorIndexing(_ service: IndexingService, error: Error?)
    func updatedProgress(_ service: IndexingService, completed: Double)
}

// MARK: - StreamService
protocol StreamServiceProtocol: AnyObject, Subservice {
    var effectsStream: AnyStreamListener? { get }
    var operationsStream: AnyStreamListener? { get }
    var transactionsStream: AnyStreamListener? { get }

    func subscribe(to stream: StreamService.StreamType, account: StellarAccount) throws
    func unsubscribe(from stream: StreamService.StreamType) throws
    func subscribeAll(account: StellarAccount)
    func unsubscribeAll()
}

public protocol StreamServiceDelegate: AnyObject {
    func receivedObjects(stream: StreamService.StreamType)
    func streamError(service: StreamService, stream: StreamService.StreamType, error: FrameworkError)
}

// MARK: - SecretManager
protocol SecretManagerProtocol: AnyObject {
    var publicKeyKey: String { get }
    var privateKeyKey: String { get }
    var secretSeedKey: String { get }
    var mnemonicKey: String { get }
    var publicKey: Data? { get }
    var privateKey: Data? { get }
    var secretSeed: String? { get }
    var mnemonic: String? { get }
}

// MARK: -
public protocol P2PResponseDelegate: AnyObject {
    func retrieved(personalToken: String?)
    func created(personalToken: String)
    func addedPeer()
    func removedPeer()
    func addFailed(error: Error)
    func removeFailed(error: Error)
    func createFailed(error: Error)
}
