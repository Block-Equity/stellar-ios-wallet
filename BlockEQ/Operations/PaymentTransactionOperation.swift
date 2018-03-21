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
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    
    static func getTransactions(accountId: String, completion: @escaping ([PaymentTransaction]) -> Void) {
        
        var paymentTransactions: [PaymentTransaction] = []
        
        sdk.payments.getPayments(forAccount: accountId, order:Order.descending, limit: 20) { response in
            switch response {
            case .success(let paymentsResponse):
                for payment in paymentsResponse.records {
                    if let paymentResponse = payment as? PaymentOperationResponse {
                        
                        let paymentTransaction = getPaymentTransaction(amount: paymentResponse.amount,
                                                                       assetType: paymentResponse.assetType,
                                                                       date: paymentResponse.createdAt,
                                                                       isAccountCreated: false,
                                                                       isPaymentReceived: paymentResponse.from != accountId ? true : false)
                        
                        paymentTransactions.append(paymentTransaction)
                    }
                    
                    if let paymentResponse = payment as? AccountCreatedOperationResponse {
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
        sdk.payments.stream(for: .paymentsForAccount(account: accountId, cursor: "now")).onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(let id, let operationResponse):
                if let paymentResponse = operationResponse as? PaymentOperationResponse {
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
    
    static private func getPaymentTransaction(amount: String, assetType: String, date: Date, isAccountCreated: Bool, isPaymentReceived: Bool) -> PaymentTransaction {
         let paymentTransaction = PaymentTransaction()
        paymentTransaction.amount = amount
        paymentTransaction.date = date
        paymentTransaction.isReceived = isPaymentReceived
        paymentTransaction.assetType = assetType
        
        return paymentTransaction
    }
}
