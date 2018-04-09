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
                
                print("Total number of accounts", accountDetails.balances.count)
                
                for accountDetail in accountDetails.balances {
                    let stellarAsset = StellarAsset()
                    stellarAsset.assetType = accountDetail.assetType
                    stellarAsset.balance = accountDetail.balance
                    stellarAsset.assetCode = accountDetail.assetCode
                    stellarAsset.assetIssuer = accountDetail.assetIssuer
                    print("Asset Type", accountDetail.assetType)
                    print("Balance", accountDetail.balance)
                    stellarAccount.assets.append(stellarAsset)
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
}
