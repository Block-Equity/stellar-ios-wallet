//
//  StellarConfig.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarConfig {
    internal struct HorizonHostURLs {
        static let production = "https://horizon.stellar.org"
        static let test = "https://horizon-testnet.stellar.org"
        static let local = "localhost:3030"
    }

    public enum HorizonURL {
        case publicAddress(HorizonAPI, StellarAddress)

        var string: String {
            switch self {
            case .publicAddress(let server, let address):
                let url = URL(string: "accounts/\(address.string)/data/PersonalAccount", relativeTo: server.url)!
                return url.absoluteString
            }
        }
    }

    public enum HorizonAPI {
        case production
        case test
        case local

        public var url: URL {
            return URL(string: self.urlString)!
        }

        public var urlString: String {
            switch self {
            case .production: return HorizonHostURLs.production
            case .test: return HorizonHostURLs.test
            case .local: return HorizonHostURLs.local
            }
        }

        public var network: Network {
            switch self {
            case .production: return Network.public
            case .test: return Network.testnet
            case .local: return Network.testnet
            }
        }
    }
}
