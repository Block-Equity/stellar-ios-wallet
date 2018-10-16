//
//  TradeOperations.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-29.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

class TradeOperation: NSObject {
    static func getOrderBook(sellingAsset: StellarAsset,
                             buyingAsset: StellarAsset,
                             completion: @escaping (OrderbookResponse) -> Void,
                             failure: @escaping (String) -> Void) {

        Stellar.sdk.orderbooks.getOrderbook(sellingAssetType: sellingAsset.assetType,
                                            sellingAssetCode: sellingAsset.assetCode,
                                            sellingAssetIssuer: sellingAsset.assetIssuer,
                                            buyingAssetType: buyingAsset.assetType,
                                            buyingAssetCode: buyingAsset.assetCode,
                                            buyingAssetIssuer: buyingAsset.assetIssuer, limit: 20) { response in
            switch response {
            case .success(let orderBookResponse):
                DispatchQueue.main.async {
                    completion(orderBookResponse)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    failure(error.localizedDescription)
                }
            }
        }
    }

    static func getOffers(completion: @escaping (PageResponse<OfferResponse>) -> Void,
                          failure: @escaping (String) -> Void) {
        guard let accountId = KeychainHelper.accountId else {
            DispatchQueue.main.async {
                failure("No account found")
            }
            return
        }

        Stellar.sdk.offers.getOffers(forAccount: accountId, cursor: nil,
                                     order: Order.descending,
                                     limit: 100) { response in
            switch response {
            case .success(let offerResponse):
                DispatchQueue.main.async {
                    completion(offerResponse)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag: "Get Offers", horizonRequestError: error)
                    failure(error.localizedDescription)
                }
            }
        }
    }

    static func cancel(assets: (selling: StellarAsset, buying: StellarAsset),
                       offerId: Int,
                       price: Price,
                       completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let buyAsset = self.getAsset(stellarAsset: assets.buying)
                    let sellAsset = self.getAsset(stellarAsset: assets.selling)

                    let manageOfferOperation = ManageOfferOperation(sourceAccount: sourceKeyPair,
                                                                    selling: sellAsset,
                                                                    buying: buyAsset,
                                                                    amount: 0,
                                                                    price: price,
                                                                    offerId: UInt64(offerId))

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [manageOfferOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)

                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Cancel Trade Offer Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Cancel Trade Error", horizonRequestError: error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private static func scaledPrice(price: (numerator: Decimal, denominator: Decimal)) -> Price {
        var num: Decimal = price.numerator
        var den: Decimal = price.denominator

        let decimalInt32Max = Decimal(Int32.max)

        let maxPlaces = Int(max(price.numerator.exponent.magnitude, price.denominator.exponent.magnitude))
        for currentPlaces in 0...maxPlaces {
            let scale: Decimal = pow(10.0, maxPlaces - currentPlaces)

            let scaledNumerator = price.numerator * scale
            let scaledDenominator = price.denominator * scale

            if scaledNumerator <= decimalInt32Max && scaledDenominator <= decimalInt32Max {
                num = scaledNumerator
                den = scaledDenominator
                break
            }
        }

        return Price(numerator: NSDecimalNumber(decimal: num).int32Value,
                     denominator: NSDecimalNumber(decimal: den).int32Value)
    }

    static func postTrade(tradePrice: (numerator: Decimal, denominator: Decimal),
                          assets: (selling: StellarAsset, buying: StellarAsset),
                          type: TradeType,
                          completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        let finalNumerator = type == .market ? tradePrice.numerator * Decimal(0.999) : tradePrice.numerator
        let price = scaledPrice(price: (finalNumerator, tradePrice.denominator))

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let buyAsset = self.getAsset(stellarAsset: assets.buying)
                    let sellAsset = self.getAsset(stellarAsset: assets.selling)

                    let manageOfferOperation = ManageOfferOperation(sourceAccount: sourceKeyPair,
                                                                    selling: sellAsset,
                                                                    buying: buyAsset,
                                                                    amount: tradePrice.denominator,
                                                                    price: price,
                                                                    offerId: 0)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [manageOfferOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)

                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Trade Offer Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Payment Error", horizonRequestError: error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    static func getAsset(stellarAsset: StellarAsset) -> Asset {
        let asset: Asset!

        if stellarAsset.assetType == AssetTypeAsString.NATIVE {
            asset = Asset(type: AssetType.ASSET_TYPE_NATIVE)!
        } else {
            guard let issuerKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: stellarAsset.assetIssuer!),
                                                   privateKey: nil) else {
                return Asset(type: AssetType.ASSET_TYPE_NATIVE)!
            }

            asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4,
                          code: stellarAsset.assetCode,
                          issuer: issuerKeyPair)
        }

        return asset
    }
}
