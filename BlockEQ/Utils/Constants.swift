//
//  Constants.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import UIKit

//swiftlint:disable line_length
struct Colors {
    static let backgroundDark =  UIColor(red: 21.0/255.0, green: 27.0/255.0, blue: 38.0/255.0, alpha: Alphas.opaque)
    static let primaryDark =  UIColor(red: 0.0/255.0, green: 106.0/255.0, blue: 255.0/255.0, alpha: Alphas.opaque)
    static let primaryDarkTransparent = UIColor(red: 1.0/255.0, green: 83.0/255.0, blue: 182.0/255.0, alpha: Alphas.transparent)
    static let secondaryDark =  UIColor(red: 0.0/255.0, green: 143.0/255.0, blue: 255.0/255.0, alpha: Alphas.opaque)
    static let secondaryDarkTransparent =  UIColor(red: 0.0/255.0, green: 143.0/255.0, blue: 255.0/255.0, alpha: Alphas.transparent)
    static let tertiaryDark =  UIColor(red: 0.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: Alphas.opaque)
    static let tertiaryDarkTransparent =  UIColor(red: 0.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: Alphas.transparent)
    static let lightBackground = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: Alphas.opaque)
    static let lightBlue = UIColor(red: 247.0/255.0, green: 249.0/255.0, blue: 253.0/255.0, alpha: Alphas.opaque)
    static let blueGray = UIColor(red: 109.0/255.0, green: 119.0/255.0, blue: 134.0/255.0, alpha: Alphas.opaque)
    static let darkGray = UIColor(red: 35.0/255.0, green: 43.0/255.0, blue: 55.0/255.0, alpha: Alphas.opaque)
    static let darkGrayTransparent = UIColor(red: 35.0/255.0, green: 43.0/255.0, blue: 55.0/255.0, alpha: Alphas.semiTransparent)
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

    static let priceDarkGray = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: Alphas.opaque)
    static let priceLightGray = UIColor(red: 0.627, green: 0.627, blue: 0.627, alpha: Alphas.opaque)

    static let collectionViewBackground = UIColor(red: 0.936, green: 0.941, blue: 0.941, alpha: Alphas.opaque)
    static let transactionCellDarkGray = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: Alphas.opaque)
    static let transactionCellMediumGray = UIColor(red: 0.565, green: 0.565, blue: 0.565, alpha: Alphas.opaque)
    static let transactionCellBorderGray = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: Alphas.opaque)
}
//swiftlint:enable line_length

public struct Alphas {
    static let opaque = CGFloat(1)
    static let opaqueTransparent = CGFloat(0.7)
    static let semiTransparent = CGFloat(0.5)
    static let transparent = CGFloat(0.2)
}

enum MenuItem {
    case wallet
    case trading
    case p2p
    case settings

    var identifier: String {
        switch self {
        case .wallet: return "menu-wallet"
        case .trading: return "menu-trading"
        case .p2p: return "menu-p2p"
        case .settings: return "menu-settings"
        }
    }

    var title: String {
        switch self {
        case .wallet: return "MENU_OPTION_WALLETS".localized()
        case .trading: return "MENU_OPTION_TRADING".localized()
        case .p2p: return "MENU_OPTION_P2P".localized()
        case .settings: return "MENU_OPTION_SETTINGS".localized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .wallet: return UIImage(named: "wallet")
        case .trading: return UIImage(named: "trading")
        case .p2p: return UIImage(named: "settings")
        case .settings: return UIImage(named: "settings")
        }
    }
}
