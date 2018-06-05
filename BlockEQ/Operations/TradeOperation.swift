//
//  TradeOperations.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-29.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class TradeOperation: NSObject {
    static func getOrderBook(sellingAsset: StellarAsset, buyingAsset: StellarAsset, completion: @escaping (OrderbookResponse) -> Void, failure: @escaping (String) -> Void) {
        Stellar.sdk.orderbooks.getOrderbook(sellingAssetType: sellingAsset.assetType, sellingAssetCode: sellingAsset.assetCode, sellingAssetIssuer: sellingAsset.assetIssuer, buyingAssetType: buyingAsset.assetType, buyingAssetCode: buyingAsset.assetCode, buyingAssetIssuer: buyingAsset.assetIssuer, limit: 20) { response in
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
    
    static func getOffers(completion: @escaping (PageResponse<OfferResponse>) -> Void, failure: @escaping (String) -> Void) {
        guard let accountId = KeychainHelper.getAccountId() else {
            DispatchQueue.main.async {
                failure("No account found")
            }
            return
        }
        
        print(accountId)
        
        Stellar.sdk.offers.getOffers(forAccount: accountId, cursor: nil, order: Order.descending, limit: 100) { response in
            switch response {
            case .success(let offerResponse):
                DispatchQueue.main.async {
                    completion(offerResponse)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Get Offers", horizonRequestError:error)
                    failure(error.localizedDescription)
                }
            }
        }
    }
    
    static func postTrade(amount: Decimal, numerator: Int, denominator: Int, sellingAsset: StellarAsset, buyingAsset: StellarAsset, completion: @escaping (Bool) -> Void) {
        guard let privateKeyData = KeychainHelper.getPrivateKey(), let publicKeyData = KeychainHelper.getPublicKey() else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        let publicBytes: [UInt8] = [UInt8](publicKeyData)
        let privateBytes: [UInt8] = [UInt8](privateKeyData)
        
        guard let sourceKeyPair = try? KeyPair(publicKey: PublicKey(publicBytes), privateKey: PrivateKey(privateBytes)) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in

            switch response {
            case .success(let accountResponse):
                do {
                    let buyAsset = self.getAsset(stellarAsset: buyingAsset)
                    let sellAsset = self.getAsset(stellarAsset: sellingAsset)
                    
                    let manageOfferOperation = ManageOfferOperation(sourceAccount: sourceKeyPair,
                                                                    selling: sellAsset,
                                                                    buying: buyAsset,
                                                                    amount: amount,
                                                                    price: Price(numerator: numerator, denominator: denominator),
                                                                    offerId: 0)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [manageOfferOperation],
                                                      memo: Memo.none,
                                                      timeBounds:nil)
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)
                    
                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                        switch response {
                        case .success(_):
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Trade Offer Error", horizonRequestError:error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
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
            guard  let issuerKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: stellarAsset.assetIssuer!), privateKey: nil) else {
                return Asset(type: AssetType.ASSET_TYPE_NATIVE)!
            }
            
            asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: stellarAsset.assetCode, issuer: issuerKeyPair)
        }
        
        return asset
    }
}
