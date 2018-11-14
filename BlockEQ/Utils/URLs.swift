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
    case assetDirectory
    case diagnosticReport
    case termsAndConditions
    case privacyPolicy
    case diagnostics

    var url: URL { return URL(string: self.string)! }

    var string: String {
        switch self {
        case .site: return "https://blockeq.com"
        case .exchangeDirectory: return "https://api.blockeq.com/directory/exchanges?asArray"
        case .assetDirectory: return "https://api.blockeq.com/directory/assets?asArray"
        case .diagnosticReport: return "https://api.blockeq.com/diagnostic"
        case .privacyPolicy: return "https://blockeq.com/privacy.html"
        case .termsAndConditions: return "https://blockeq.com/terms.html"
        case .diagnostics: return "https://api.airtable.com/v0/app09oC6VlZ8iDpWP/Reports"
        }
    }
}
