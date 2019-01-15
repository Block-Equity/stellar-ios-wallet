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

enum BlockEQAPIEnvironment {
    case production
    case staging
    case debug

    var string: String {
        switch self {
        case .production: return "https://api.blockeq.com"
        case .staging: return "https://api-staging.blockeq.com"
        case .debug: return "http://localhost:8080"
        }
    }
}

enum BlockEQSiteEnvironment {
    case production
    case staging
    case debug

    var string: String {
        switch self {
        case .production: return "https://blockeq.com"
        case .staging: return "https://staging.blockeq.com"
        case .debug: return "http://localhost:8080"
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
    case assetIcon(String)

    var url: URL { return URL(string: self.string)! }

    var string: String {
        switch self {
        case .site: return siteEnv.string
        case .exchangeDirectory: return "\(apiEnv.string)/directory/exchanges?asArray"
        case .assetDirectory: return "\(apiEnv.string)/directory/assets?asArray"
        case .diagnosticReport: return "\(apiEnv.string)/diagnostic"
        case .privacyPolicy: return "\(siteEnv.string)/privacy.html"
        case .termsAndConditions: return "\(siteEnv.string)/terms.html"
        case .assetIcon(let shortCode):
            return "https://s3.amazonaws.com/blockeq-wallet-shared/icons/128/color/\(shortCode).png"
        }
    }
}

#if DEBUG
private let apiEnv: BlockEQAPIEnvironment = .staging
private let siteEnv: BlockEQSiteEnvironment = .staging
#else
private let apiEnv: BlockEQAPIEnvironment = .production
private let siteEnv: BlockEQSiteEnvironment = .production
#endif
