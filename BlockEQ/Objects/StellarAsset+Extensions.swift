//
//  StellarAsset+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

public struct Assets {
    enum AssetType: String, CaseIterable {
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

extension StellarAsset {
    var title: String {
        switch shortCode.uppercased() {
        case "XLM": return "Stellar Lumens"
        case "PTS": return "Block Points"
        case "CAD": return "Canadian Dollar"
        default: return shortCode
        }
    }

    func issuer(for account: String?) -> String {
        switch account {
        case "GBPG7KRYC3PTKHBXQGRD3GMZ5DB4C3D553ZN2ZLH57LBAQIULVY46Z5F":
            return "Block Equity"
        case "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S":
            return "Block Equity"
        default:
            return ""
        }
    }

    var subtitleWithIssuer: String {
        let issuer = self.issuer(for: assetIssuer)
        let uppercaseShortCode = shortCode.uppercased()

        if issuer.isEmpty {
            return String(format: "%@", uppercaseShortCode)
        }

        return String(format: "%@ (%@)", uppercaseShortCode, issuer)
    }

    var headerIcon: UIImage? {
        let lowercaseShortCode = shortCode.lowercased()
        return UIImage(named: lowercaseShortCode)
    }

    var headerViewModel: AssetHeaderView.ViewModel {
        return AssetHeaderView.ViewModel(image: headerIcon,
                                         assetTitle: title,
                                         assetSubtitle: subtitleWithIssuer)
    }

    var priceViewModel: AssetPriceView.ViewModel {
        let assetBalance = self.hasZeroBalance ? "NOT_AVAILABLE_SHORTFORM".localized() : balance
        let assetPrice = ""
        return AssetPriceView.ViewModel(amount: assetBalance.displayFormatted, price: assetPrice)
    }

    var primaryColor: UIColor {
        return UIColor(red: 0.086, green: 0.712, blue: 0.905, alpha: 1.000)
    }
}
