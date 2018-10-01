//
//  PaymentOperation.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Alamofire
import stellarsdk
import UIKit

class PaymentTransactionOperation: NSObject {
    static func getTransactions(accountId: String,
                                stellarAsset: StellarAsset,
                                completion: @escaping ([StellarEffect]) -> Void) {

        Stellar.sdk.effects.getEffects(forAccount: accountId,
                                       from: nil,
                                       order: Order.descending,
                                       limit: 200) { response -> Void in
            switch response {
            case .success(let effectsResponse):

                var stellarEffects: [StellarEffect] = []

                for effect in effectsResponse.records {
                    let stellarEffect = StellarEffect(effect: effect)
                    let matchingBoughtAsset = stellarEffect.boughtAsset == stellarAsset
                    let matchingSoldAsset = stellarEffect.soldAsset == stellarAsset

                    if stellarEffect.type == .trade && (matchingBoughtAsset || matchingSoldAsset) {
                        stellarEffects.append(stellarEffect)
                    } else if stellarEffect.type != .accountCreated && stellarEffect.asset == stellarAsset {
                        stellarEffects.append(stellarEffect)
                    }
                }

                DispatchQueue.main.async {
                    completion(stellarEffects)
                }

            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Error getting effects", horizonRequestError: error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    static func checkForExchange(address: String, completion: @escaping (String?) -> Void) {
        let decoder = JSONDecoder()
        Alamofire.request(BlockEQURL.exchangeDirectory.string).responseJSON { response in
            guard response.result.isSuccess, let data = response.data else {
                print("Error while fetching exchanges: \(String(describing: response.result.error))")
                completion(nil)
                return
            }

            do {
                let exchangeList = try decoder.decode([Exchange].self, from: data)
                if let exchange = exchangeList.first(where: { $0.address == address }) {
                    completion(exchange.name)
                    return
                }
            } catch let error {
                print("Error decoding exchange list: \(error.localizedDescription)")
                completion(nil)
                return
            }

            completion(nil)
        }
    }

    static func postPayment(accountId: String, amount: Decimal,
                            memoId: String,
                            stellarAsset: StellarAsset,
                            completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair,
            let destinationKeyPair = KeychainHelper.issuerKeyPair(accountId: accountId) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let asset: Asset!
                    if stellarAsset.assetType == AssetTypeAsString.NATIVE {
                        asset = Asset(type: AssetType.ASSET_TYPE_NATIVE)!
                    } else {
                        guard let keyPair = KeychainHelper.issuerKeyPair(accountId: stellarAsset.assetIssuer!) else {
                            DispatchQueue.main.async { completion(false) }
                            return
                        }

                        asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4,
                                      code: stellarAsset.assetCode,
                                      issuer: keyPair)
                    }

                    let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                            destination: destinationKeyPair,
                                                            asset: asset,
                                                            amount: amount)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [paymentOperation],
                                                      memo: createMemo(from: memoId),
                                                      timeBounds: nil)

                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async { completion(true) }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Payment Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async { completion(false) }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Payment Error", horizonRequestError: error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func changeTrust(issuerAccountId: String,
                            assetCode: String,
                            limit: Decimal,
                            completion: @escaping (Bool) -> Void) {

        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        guard let issuerKeyPair = KeychainHelper.issuerKeyPair(accountId: issuerAccountId) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        guard let asset = Asset.init(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4,
                                     code: assetCode,
                                     issuer: issuerKeyPair) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let changeTrustOperation = ChangeTrustOperation(sourceAccount: sourceKeyPair,
                                                                    asset: asset,
                                                                    limit: limit)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)

                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async { completion(true) }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Change Trust Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async { completion(false) }
                            return
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Change Trust Error",
                                                              horizonRequestError: error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func changeP2PTrust(issuerAccountId: String,
                               assetCode: String,
                               limit: Decimal,
                               completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        guard let issuerKeyPair = KeychainHelper.issuerKeyPair(accountId: issuerAccountId) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        guard let asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM12,
                                code: assetCode,
                                issuer: issuerKeyPair) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let changeTrustOperation = ChangeTrustOperation(sourceAccount: sourceKeyPair,
                                                                    asset: asset,
                                                                    limit: limit)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)

                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async { completion(true) }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Change Trust Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async { completion(false) }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Change Trust Error",
                                                              horizonRequestError: error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
}

private func createMemo(from memoId: String) -> Memo {
    var memo = Memo.none

    if !memoId.isEmpty {
        if let memoNumber = UInt64(memoId) {
            memo = Memo.id(memoNumber)
        } else {
            memo = Memo.text(memoId)
        }
    }

    return memo
}
