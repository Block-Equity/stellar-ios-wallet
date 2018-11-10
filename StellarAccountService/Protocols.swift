//
//  Protocols.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

protocol CoreService {
    var sdk: StellarSDK { get }
    var api: StellarConfig.HorizonAPI { get }
    var services: [Subservice] { get }
    var secretManager: SecretManagerProtocol? { get }
    var walletKeyPair: KeyPair? { get }
}

protocol Subservice {
    var core: CoreService { get }
}

protocol StellarAccountServiceProtocol: AnyObject, Subservice {
    var core: CoreService { get }
    var subscribers: MulticastDelegate<StellarAccountServiceDelegate> { get set }
    var state: StellarAccountService.AccountState { get }
    var secretManager: SecretManager? { get set }
    var account: StellarAccount? { get set }
}

protocol StellarTradeServiceProtocol: AnyObject, Subservice {
    var core: CoreService { get }
    var tradeQueue: OperationQueue { get }
}

protocol StellarIndexingServiceProtocol: Subservice {
    func updateIndex()
    func rebuildIndex()
    func reset()
    func pause()
    func resume()
    func relatedObject<In: IndexableStellarObject, Out: IndexableStellarObject>(startingAt object: In) -> Out?
}

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

public protocol AccountUpdatable: AnyObject {
    func updated(account: StellarAccount)
}

// MARK: -
public protocol SendAmountResponseDelegate: AnyObject {
    func sentAmount(destination: StellarAddress)
    func failed(error: Error)
}

// MARK: -
public protocol SetInflationResponseDelegate: AnyObject {
    func setInflation(destination: StellarAddress)
    func failed(error: StellarAccountService.ServiceError)
}

// MARK: -
public protocol ManageAssetResponseDelegate: AnyObject {
    func added(asset: StellarAsset, account: StellarAccount)
    func removed(asset: StellarAsset, account: StellarAccount)
    func failed(error: Error)
}

// MARK: -
public protocol TradeResponseDelegate: AnyObject {
    func cancelled(offerId: Int, trade: StellarTradeOfferData)
    func posted(trade: StellarTradeOfferData)
    func cancellationFailed(error: Error)
    func postingFailed(error: Error)
}

// MARK: -
public protocol OfferResponseDelegate: AnyObject {
    func updated(orders: StellarOrderbook)
    func updated(offers: [StellarAccountOffer])
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

// MARK: -
public protocol StellarIndexingServiceDelegate: AnyObject {
    func finishedIndexing(_ service: StellarIndexingService)
    func updatedProgress(_ service: StellarIndexingService, progress: Progress)
}
