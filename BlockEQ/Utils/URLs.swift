//
//  URLs.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

enum HorizonURL {
    case publicAddress(String)

    var url: URL {
        return URL(string: self.string)!
    }

    var string: String {
        switch self {
        case .publicAddress(let address): return "https://horizon.stellar.org/accounts/\(address)/data/PersonalAccount"
        }
    }
}

enum BlockEQURL {
    case exchangeDirectory

    var url: URL { return URL(string: self.string)! }

    var string: String {
        return "https://blockeq-wallet.firebaseio.com/exchangeAddresses.json"
    }
}
