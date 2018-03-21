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
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    
    static func getAccountDetails(accountId: String, completion: @escaping ([StellarAccount]) -> Void) {
        
        var accounts: [StellarAccount] = []
        
        sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountDetails.accountId
                stellarAccount.balance = accountDetails.balances[0].balance
                
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
}
