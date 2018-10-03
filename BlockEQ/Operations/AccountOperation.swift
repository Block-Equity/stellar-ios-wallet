//
//  AccountOperation.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Alamofire
import stellarsdk
import UIKit

public class AccountOperation {
    static func getAccountDetails(accountId: String, completion: @escaping ([StellarAccount]) -> Void) {

        var accounts: [StellarAccount] = []

        Stellar.sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> Void in
            switch response {
            case .success(let accountDetails):
                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountDetails.accountId
                stellarAccount.inflationDestination = accountDetails.inflationDestination
                stellarAccount.totalTrustlines = accountDetails.balances.count - 1
                stellarAccount.totalSigners = accountDetails.signers.count
                stellarAccount.totalOffers = Int(accountDetails.subentryCount) - stellarAccount.totalTrustlines

                stellarAccount.assets.removeAll()

                for accountDetail in accountDetails.balances {
                    let stellarAsset = StellarAsset(assetType: accountDetail.assetType,
                                                    assetCode: accountDetail.assetCode,
                                                    assetIssuer: accountDetail.assetIssuer,
                                                    balance: accountDetail.balance)

                    if accountDetail.assetType == AssetTypeAsString.NATIVE {
                        stellarAccount.assets.insert(stellarAsset, at: 0)
                    } else {
                        stellarAccount.assets.append(stellarAsset)
                    }
                }

                accounts.append(stellarAccount)

                DispatchQueue.main.async {
                    completion(accounts)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(accounts)
                }
            }
        }
    }

    static func createNewAccount(accountId: String,
                                 amount: Decimal,
                                 completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        guard let destinationKeyPair = try? KeyPair(publicKey: PublicKey(accountId: accountId), privateKey: nil) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: amount)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [createAccount],
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
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Create account",
                                                                          horizonRequestError: error)
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
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Error:", horizonRequestError: error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    static func setInflationDestination(accountId: String, completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        guard let inflationKeyPair = try? KeyPair(publicKey: PublicKey(accountId: accountId), privateKey: nil) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let setOptionsOperation = try SetOptionsOperation(sourceAccount: sourceKeyPair,
                                                                      inflationDestination: inflationKeyPair,
                                                                      clearFlags: nil,
                                                                      setFlags: nil,
                                                                      masterKeyWeight: nil,
                                                                      lowThreshold: nil,
                                                                      mediumThreshold: nil,
                                                                      highThreshold: nil,
                                                                      homeDomain: nil,
                                                                      signer: nil,
                                                                      signerWeight: nil)

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [setOptionsOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async { completion(true) }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Inflation Destination Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async { completion(false) }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Inflation Destination Error",
                                                              horizonRequestError: error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func createPersonalToken(assetCode: String, completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = KeychainHelper.walletKeyPair else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> Void in
            switch response {
            case .success(let accountResponse):
                do {
                    let manageDataOperation = ManageDataOperation(sourceAccount: sourceKeyPair,
                                                                  name: "PersonalAccount",
                                                                  data: assetCode.data(using: .utf8))

                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [manageDataOperation],
                                                      memo: Memo.none,
                                                      timeBounds: nil)
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)

                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> Void in
                        switch response {
                        case .success:
                            DispatchQueue.main.async { completion(true) }
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Create Token Error",
                                                                          horizonRequestError: error)
                            DispatchQueue.main.async { completion(false) }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag: "Post Create Token Error",
                                                              horizonRequestError: error)
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func getPersonalToken(address: String, completion: @escaping (String?) -> Void) {
        Alamofire.request(HorizonURL.publicAddress(address).string).responseJSON { response in
            guard response.result.isSuccess, let value = response.result.value as? [String: Any] else {
                print("Error while fetching account: \(String(describing: response.result.error))")
                completion(nil)
                return
            }

            guard let personalAccount = value["value"] as? String else {
                completion(nil)
                return
            }

            guard let decodedValue = personalAccount.base64Decoded() else {

                completion(nil)
                return
            }

            completion(decodedValue)
        }
    }
}
