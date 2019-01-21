//
//  StellarConfig.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarConfig {
    internal struct HorizonHostURLs {
        static let production = "https://horizon.stellar.org"
        static let testnet = "https://horizon-testnet.stellar.org"
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
        case testnet
        case custom(String)

        public var url: URL {
            return URL(string: self.urlString)!
        }

        public var urlString: String {
            switch self {
            case .production: return HorizonHostURLs.production
            case .testnet: return HorizonHostURLs.testnet
            case .custom(let host):
                guard let customHost = URL(string: host) else {
                    return HorizonHostURLs.testnet
                }

                return customHost.absoluteString
            }
        }

        public var network: Network {
            switch self {
            case .production: return Network.public
            case .testnet: return Network.testnet
            case .custom: return Network.testnet
            }
        }

        public static func from(string: String?) -> HorizonAPI {
            guard let networkName = string else { return .production }

            if networkName.lowercased().contains("production") {
                return .production
            } else if networkName.lowercased().contains("testnet") {
                return .testnet
            } else {
                return .custom(networkName)
            }
        }
    }
}
