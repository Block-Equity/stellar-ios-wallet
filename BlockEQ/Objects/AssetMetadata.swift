//
//  AssetMetadata.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

public struct AssetMetadata: Hashable {
    static let staticAssetCodes = ["PTS", "CAD"]

    let shortCode: String
    let displayName: String
    let primaryColor: UIColor
    let issuerName: String?
    let issuerAddress: String?

    init(shortCode: String) {
        let code = shortCode.uppercased()
        self.shortCode = code

        let asset = AssetMetadataManager.shared.assets[code]
        self.displayName = asset?.displayName ?? shortCode
        self.primaryColor = asset?.primaryColor ?? Colors.stellarBlue
        self.issuerName = asset?.issuerName
        self.issuerAddress = asset?.issuerAddress
    }

    var image: UIImage? {
        let lowercaseShortCode = shortCode.lowercased()
        return UIImage(named: lowercaseShortCode)
    }

    var displayNameWithShortCode: String {
        return "\(displayName) (\(shortCode))"
    }

    var subtitleWithIssuer: String {
        return issuerName != nil ? "\(shortCode) (\(issuerName!))" : "\(shortCode)"
    }
}

extension AssetMetadata: Decodable {
    enum CodingKeys: String, CodingKey {
        case shortCode = "short_code"
        case displayName = "display_name"
        case primaryColor = "primary_color"
        case issuerName = "issuer_name"
        case issuerAddress = "issuer_address"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shortCode = try container.decode(String.self, forKey: .shortCode)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.issuerAddress = try container.decodeIfPresent(String.self, forKey: .issuerAddress)
        self.issuerName = try container.decodeIfPresent(String.self, forKey: .issuerName)

        let colorString = try container.decode(String.self, forKey: .primaryColor)
        self.primaryColor = UIColor(hex: colorString)
    }
}
