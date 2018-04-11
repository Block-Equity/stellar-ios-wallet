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
    static func getTransactions(accountId: String, stellarAsset: StellarAsset, completion: @escaping ([PaymentTransaction]) -> Void) {
        
        var paymentTransactions: [PaymentTransaction] = []
        
        Stellar.sdk.payments.getPayments(forAccount: accountId, order:Order.descending, limit: 20) { response in
            switch response {
            case .success(let paymentsResponse):
                for payment in paymentsResponse.records {
                    if let paymentResponse = payment as? PaymentOperationResponse, paymentResponse.assetCode == stellarAsset.assetCode, paymentResponse.assetType == stellarAsset.assetType {
                        let paymentTransaction = getPaymentTransaction(amount: paymentResponse.amount,
                                                                       assetType: paymentResponse.assetType,
                                                                       date: paymentResponse.createdAt,
                                                                       isAccountCreated: false,
                                                                       isPaymentReceived: paymentResponse.from != accountId ? true : false)
                        
                        paymentTransactions.append(paymentTransaction)
                    }
                    
                    if let paymentResponse = payment as? AccountCreatedOperationResponse, stellarAsset.assetType == AssetTypeAsString.NATIVE  {
                        let paymentTransaction = getPaymentTransaction(amount: String(describing: paymentResponse.startingBalance),
                                                                       assetType: AssetTypeAsString.NATIVE,
                                                                       date: paymentResponse.createdAt,
                                                                       isAccountCreated: true,
                                                                       isPaymentReceived: false)
                        
                        paymentTransactions.append(paymentTransaction)
                    }
                }
                DispatchQueue.main.async {
                    completion(paymentTransactions)
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(paymentTransactions)
                }
            }
        }
    }
    
    static func receivedPayment(accountId: String, completion: @escaping (Bool) -> Void) {
        Stellar.sdk.payments.stream(for: .paymentsForAccount(account: accountId, cursor: "now")).onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(_, let operationResponse):
                if operationResponse is PaymentOperationResponse {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            case .error(let error):
                if let horizonRequestError = error as? HorizonRequestError {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Receive payment", horizonRequestError:horizonRequestError)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
    }
    
    static func postPayment(accountId: String, amount: Decimal, memoId: String, completion: @escaping (Bool) -> Void) {
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
                    let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                            destination: destinationKeyPair,
                                                            asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
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
    
    static private func getPaymentTransaction(amount: String, assetType: String, date: Date, isAccountCreated: Bool, isPaymentReceived: Bool) -> PaymentTransaction {
         let paymentTransaction = PaymentTransaction()
        paymentTransaction.amount = amount
        paymentTransaction.date = date
        paymentTransaction.isReceived = isPaymentReceived
        paymentTransaction.isAccountCreated = isAccountCreated
        paymentTransaction.assetType = assetType
        
        return paymentTransaction
    }
}
