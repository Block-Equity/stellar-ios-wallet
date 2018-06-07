//
//  PaymentOperation.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-21.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class PaymentTransactionOperation: NSObject {
    static func getTransactions(accountId: String, stellarAsset: StellarAsset, completion: @escaping ([StellarEffect]) -> Void) {
        Stellar.sdk.effects.getEffects(forAccount: accountId, from: nil, order: Order.descending, limit: 200) { response -> (Void) in
            switch response {
            case .success(let effectsResponse):
                var stellarEffects: [StellarEffect] = []
                
                for effect in effectsResponse.records {
                    let stellarEffect = StellarEffect(effect: effect)
                    
                    if stellarEffect.type == .trade {
                        if stellarEffect.boughtAsset.assetType == stellarAsset.assetType && stellarEffect.boughtAsset.assetCode == stellarAsset.assetCode && stellarEffect.boughtAsset.assetIssuer == stellarAsset.assetIssuer || stellarEffect.soldAsset.assetType == stellarAsset.assetType && stellarEffect.soldAsset.assetCode == stellarAsset.assetCode && stellarEffect.soldAsset.assetIssuer == stellarAsset.assetIssuer {
                            stellarEffects.append(stellarEffect)
                        }
                    } else if stellarEffect.type != .accountCreated {
                        if  stellarEffect.asset.assetType == stellarAsset.assetType && stellarEffect.asset.assetCode == stellarAsset.assetCode && stellarEffect.asset.assetIssuer == stellarAsset.assetIssuer  {
                            stellarEffects.append(stellarEffect)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(stellarEffects)
                }
                
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    static func postPayment(accountId: String, amount: Decimal, memoId: String, stellarAsset: StellarAsset, completion: @escaping (Bool) -> Void) {
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
        
        guard  let destinationKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: accountId), privateKey: nil) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            var memo = Memo.none
            
            if !memoId.isEmpty {
                if let memoNumber = UInt64(memoId) {
                    memo = Memo.id(memoNumber)
                }
            }
            
            switch response {
            case .success(let accountResponse):
                do {
                    let asset: Asset!
                    if stellarAsset.assetType == AssetTypeAsString.NATIVE {
                        asset = Asset(type: AssetType.ASSET_TYPE_NATIVE)!
                    } else {
                        guard  let issuerKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: stellarAsset.assetIssuer!), privateKey: nil) else {
                            DispatchQueue.main.async {
                                completion(false)
                            }
                            return
                        }
                        
                        asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: stellarAsset.assetCode, issuer: issuerKeyPair)
                    }
                    
                    let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                            destination: destinationKeyPair,
                                                            asset: asset,
                                                            amount: amount)
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [paymentOperation],
                                                      memo: memo,
                                                      timeBounds:nil)
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)
                    
                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                        switch response {
                        case .success(_):
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
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
    
    static func changeTrust(issuerAccountId: String, assetCode: String, completion: @escaping (Bool) -> Void) {
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
        
        guard  let issuerKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: issuerAccountId), privateKey: nil) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        guard let asset = Asset.init(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: assetCode, issuer: issuerKeyPair) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in

            switch response {
            case .success(let accountResponse):
                do {
                    let changeTrustOperation = ChangeTrustOperation(sourceAccount: sourceKeyPair, asset: asset, limit: 10000000000)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOperation],
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
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Change Trust Error", horizonRequestError:error)
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
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Change Trust Error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
