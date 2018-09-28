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
    case site
    case exchangeDirectory
    case termsAndConditions
    case privacyPolicy

    var url: URL { return URL(string: self.string)! }

    var string: String {
        switch self {
        case .site:
            return "https://blockeq.com"
        case .exchangeDirectory:
            return "https://blockeq-wallet.firebaseio.com/exchangeAddresses.json"
        case .privacyPolicy:
            return "https://blockeq.com/privacy.html"
        case .termsAndConditions:
            return "https://blockeq.com/terms.html"
        }

    }
}
