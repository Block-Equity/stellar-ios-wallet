//
//  StellarAsset+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

public struct Assets {
    enum AssetType: String {
        case points = "PTS"
        case cad = "CAD"

        var shortForm: String {
            return self.rawValue
        }

        var issuerAccount: String {
            switch self {
            case .points: return "GBPG7KRYC3PTKHBXQGRD3GMZ5DB4C3D553ZN2ZLH57LBAQIULVY46Z5F"
            case .cad: return "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S"
            }
        }
    }

    static let all: [AssetType] = [.points, .cad]

    static func cellDisplay(shortCode: String?) -> String {
        if let assetCode = shortCode {
            return assetCode
        }
        return "XLM"
    }

    static func displayTitle(shortCode: String) -> String {
        if shortCode == "XLM" {
            return "Stellar Lumens"
        } else if shortCode == "PTS" {
            return "Block Points"
        } else if shortCode == "CAD" {
            return "Canadian Dollar"
        }
        return shortCode
    }

    static func displayImage(shortCode: String) -> UIImage? {
        if shortCode == "XLM" {
            return UIImage(named: "stellar")
        } else if shortCode == "PTS" {
            return UIImage(named: "blockpoints")
        } else if shortCode == "CAD" {
            return UIImage(named: "canada")
        }
        return nil
    }

    static func formattedDisplayTitle(asset: StellarAsset) -> String {
        if self.displayTitle(shortCode: asset.shortCode) == asset.shortCode {
            return "\(Assets.displayTitle(shortCode: asset.shortCode))"
        } else {
            return "\(Assets.displayTitle(shortCode: asset.shortCode)) (\(asset.shortCode))"
        }
    }

    static func displayImageBackgroundColor(shortCode: String) -> UIColor {
        if shortCode == "XLM" {
            return Colors.stellarBlue
        } else if shortCode == "PTS" {
            return Colors.primaryDark
        } else if shortCode == "CAD" {
            return Colors.white
        }
        return Colors.blueGray
    }
}
