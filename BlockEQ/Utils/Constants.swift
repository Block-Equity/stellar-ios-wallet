//
//  Constants.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

struct Colors {
    static let primaryDark =  UIColor(red: 1.0/255.0, green: 83.0/255.0, blue: 182.0/255.0, alpha: Alphas.opaque)
    static let primaryDarkTransparent = UIColor(red: 1.0/255.0, green: 83.0/255.0, blue: 182.0/255.0, alpha: Alphas.transparent)
    static let secondaryDark =  UIColor(red: 7.0/255.0, green: 35.0/255.0, blue: 122.0/255.0, alpha: Alphas.opaque)
    static let secondaryDarkTransparent =  UIColor(red: 7.0/255.0, green: 35.0/255.0, blue: 122.0/255.0, alpha: Alphas.transparent)
    static let tertiaryDark =  UIColor(red: 0.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: Alphas.opaque)
    static let tertiaryDarkTransparent =  UIColor(red: 0.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: Alphas.transparent)
    static let lightBackground = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: Alphas.opaque)
    static let lightBlue = UIColor(red: 247.0/255.0, green: 249.0/255.0, blue: 253.0/255.0, alpha: Alphas.opaque)
    static let blueGray = UIColor(red: 109.0/255.0, green: 119.0/255.0, blue: 134.0/255.0, alpha: Alphas.opaque)
    static let darkGray = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: Alphas.opaque)
    static let darkGrayTransparent = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: Alphas.semiTransparent)
    static let lightGray = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: Alphas.opaque)
    static let lightGrayTransparent = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: Alphas.semiTransparent)
    static let shadowGray = UIColor.lightGray
    static let black = UIColor.black
    static let blackTransparent = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: Alphas.semiTransparent)
    static let white = UIColor.white
    static let whiteTransparent = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: Alphas.transparent)
    static let green = UIColor(red: 72.0/255.0, green: 209.0/255.0, blue: 72.0/255.0, alpha: Alphas.opaque)
    static let greenTransparent = UIColor(red: 72.0/255.0, green: 209.0/255.0, blue: 72.0/255.0, alpha: Alphas.opaqueTransparent)
    static let red = UIColor(red: 255.0/255.0, green: 105.0/255.0, blue: 97.0/255.0, alpha: Alphas.opaque)
    static let stellarBlue = UIColor(red: 205.0/255.0, green: 224.0/255.0, blue: 232.0/255.0, alpha: Alphas.opaque)
    static let transparent = UIColor.clear
}

public struct Alphas {
    static let opaque = CGFloat(1)
    static let opaqueTransparent = CGFloat(0.7)
    static let semiTransparent = CGFloat(0.5)
    static let transparent = CGFloat(0.2)
}

public struct HorizonServer {
    static let production = "https://horizon.stellar.org"
    static let test = "https://horizon-testnet.stellar.org"
    static let url = HorizonServer.production
}

public struct Stellar {
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    static let network = Network.public
}

public struct Assets {
    enum AssetType: Int {
        case points
        case cad
        
        var shortForm: String {
            switch self {
            case .points:
                return "PTS"
            case .cad:
                return "CAD"
            }
        }
        
        var issuerAccount: String {
            switch self {
            case .points:
                return "GBPG7KRYC3PTKHBXQGRD3GMZ5DB4C3D553ZN2ZLH57LBAQIULVY46Z5F"
            case .cad:
                return "GABK2IHWW7BCRPP3BL6WMOMDBPHCBJR2SLP5HAUBYKNZG5J5RJSROS5S"
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
        return ""
    }
    
    static func displayImage(shortCode: String) -> UIImage? {
        if shortCode == "XLM" {
            return UIImage(named: "stellar")
        } else if shortCode == "PTS" {
            return UIImage(named: "blockpoints")
        } else if shortCode == "CAD" {
            return UIImage(named: "canada")
        }
        return UIImage(named: "")
    }
    
    static func displayImageBackgroundColor(shortCode: String) -> UIColor {
        if shortCode == "XLM" {
            return Colors.stellarBlue
        } else if shortCode == "PTS" {
            return Colors.primaryDark
        } else if shortCode == "CAD" {
            return Colors.white
        }
        return Colors.white
    }
}

enum MenuItem {
    case wallet
    case trading
    case settings

    var identifier: String {
        switch self {
        case .wallet: return "menu-wallet"
        case .trading: return "menu-trading"
        case .settings: return "menu-settings"
        }
    }

    var title: String {
        switch self {
        case .wallet: return "MENU_OPTION_WALLETS".localized()
        case .trading: return "MENU_OPTION_TRADING".localized()
        case .settings: return "MENU_OPTION_SETTINGS".localized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .wallet: return UIImage(named: "wallet")
        case .trading: return UIImage(named: "trading")
        case .settings: return UIImage(named: "settings")
        }
    }
}

