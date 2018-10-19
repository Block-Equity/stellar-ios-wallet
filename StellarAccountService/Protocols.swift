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
    var secretManager: SecretManager? { get }
    var walletKeyPair: KeyPair? { get }
}

protocol Subservice {
    var core: CoreService { get }
}

// MARK: -
public protocol SendAmountResponseDelegate: AnyObject {
    func sentAmount(destination: StellarAddress)
    func failed(error: Error)
}

// MARK: -
public protocol SetInflationResponseDelegate: AnyObject {
    func setInflation(destination: StellarAddress)
    func failed(error: Error)
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
