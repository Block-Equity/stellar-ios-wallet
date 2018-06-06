//
//  AccountOperation.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-21.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

public class AccountOperation {
    static func getAccountDetails(accountId: String, completion: @escaping ([StellarAccount]) -> Void) {
        
        var accounts: [StellarAccount] = []
        
        Stellar.sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountDetails.accountId
                stellarAccount.assets.removeAll()
                
                for accountDetail in accountDetails.balances {
                    let stellarAsset = StellarAsset(assetType: accountDetail.assetType, assetCode: accountDetail.assetCode, assetIssuer: accountDetail.assetIssuer, balance: accountDetail.balance)
                    
                    if accountDetail.assetType == AssetTypeAsString.NATIVE {
                        stellarAccount.assets.insert(stellarAsset, at: 0)
                    } else{
                        stellarAccount.assets.append(stellarAsset)
                    }
                }
                                
                accounts.append(stellarAccount)
                
                DispatchQueue.main.async {
                    completion(accounts)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    completion(accounts)
                }
            }
        }
    }
    
    static func createNewAccount(accountId: String, amount: Decimal, completion: @escaping (Bool) -> Void) {
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
            switch response {
            case .success(let accountResponse):
                do {
                    let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: amount)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [createAccount],
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
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Create account", horizonRequestError: error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .failure(let error): // error loading account details
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    static func setInflationDestination(accountId: String, completion: @escaping (Bool) -> Void) {
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
        
        guard  let inflationDestKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: accountId), privateKey: nil) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            
            switch response {
            case .success(let accountResponse):
                do {
                    let setOptionsOperation = try SetOptionsOperation(sourceAccount: sourceKeyPair, inflationDestination: inflationDestKeyPair, clearFlags: nil, setFlags: nil, masterKeyWeight: nil, lowThreshold: nil, mediumThreshold: nil, highThreshold: nil, homeDomain: nil, signer: nil, signerWeight: nil)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [setOptionsOperation],
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
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Inflation Destination Error", horizonRequestError:error)
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
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Inflation Destination Error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
