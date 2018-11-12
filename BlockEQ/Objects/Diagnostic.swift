//
//  Diagnostic.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

enum DiagnosticSupportSummary: String, RawRepresentable {
    case paymentsFailing = "My payments are failing"
    case exchangeMissingFunds = "The exchange hasn’t received my funds"
    case incorrectMemo = "I sent an incorrect memo"
    case crashing = "The app is crashing"
    case cantAddAssets = "I can’t add more assets"
    case cantTrade = "My trades are failing"
    case receivingSmallTransactions = "I’m receiving small transactions"
}

struct Diagnostic {
    static let deviceNamesByCode: [String: String] = [
        "i386": "Simulator",
        "x86_64": "Simulator",
        "iPod1,1": "iPod Touch",
        "iPod2,1": "iPod Touch",
        "iPod3,1": "iPod Touch",
        "iPod4,1": "iPod Touch",
        "iPod7,1": "iPod Touch",
        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone",
        "iPhone2,1": "iPhone",
        "iPad1,1": "iPad",
        "iPad2,1": "iPad 2",
        "iPad3,1": "iPad",
        "iPhone3,1": "iPhone 4",
        "iPhone3,3": "iPhone 4",
        "iPhone4,1": "iPhone 4S",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPad3,4": "iPad",
        "iPad2,5": "iPad Mini",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6S",
        "iPhone8,2": "iPhone 6S Plus",
        "iPhone8,4": "iPhone SE",
        "iPhone9,1": "iPhone 7",
        "iPhone9,3": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,4": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPad4,1": "iPad Air",
        "iPad4,2": "iPad Air",
        "iPad4,4": "iPad Mini",
        "iPad4,5": "iPad Mini",
        "iPad4,7": "iPad Mini",
        "iPad6,7": "iPad Pro (12.9\")",
        "iPad6,8": "iPad Pro (12.9\")",
        "iPad6,3": "iPad Pro (9.7\")",
        "iPad6,4": "iPad Pro (9.7\")",
        "iPad6,11": "iPad (5th gen)",
        "iPad6,12": "iPad (5th gen)",
        "iPad7,1": "iPad Pro (12.9\" - 2nd gen)",
        "iPad7,2": "iPad Pro (12.9\" - 2nd gen)",
        "iPad7,3": "iPad Pro (10.5\" - 2nd gen)",
        "iPad7,4": "iPad Pro (10.5\" - 2nd gen)",
        "iPad7,5": "iPad (6th gen)",
        "iPad7,6": "iPad (6th gen)",
        "iPad8,1": "iPad Pro (11\" - 3rd gen)",
        "iPad8,2": "iPad Pro (11\" - 3rd gen)",
        "iPad8,3": "iPad Pro (11\" - 3rd gen)",
        "iPad8,4": "iPad Pro (11\" - 3rd gen)",
        "iPad8,5": "iPad Pro (12.9\" - 3rd gen)",
        "iPad8,6": "iPad Pro (12.9\" - 3rd gen)",
        "iPad8,7": "iPad Pro (12.9\" - 3rd gen)",
        "iPad8,8": "iPad Pro (12.9\" - 3rd gen)"
    ]

    enum CreationMethod: String, RawRepresentable {
        case mnemonic12 = "12-word Mnemonic"
        case mnemonic24 = "24-word Mnemonic"
        case recoveredSeed = "Recovered from Secret Seed"
        case recoveredMnemonic = "Recovered from Mnemonic"
    }

    var walletAddress: String?
    var walletCreationMethod: CreationMethod?
    var walletPassphrase: Bool?
    let emailAddress: String
    let issueSummary: String

    var appVersion: String {
        return DeviceString.version.value
    }

    var rawHardwareDevice: String {
        return UIDevice.current.modelName
    }

    var locale: String {
        return "\(NSLocale.current.languageCode ?? "??")-\(NSLocale.current.regionCode ?? "??")"
    }

    var osVersion: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    var batteryState: String {
        switch UIDevice.current.batteryState {
        case .unknown: return "Unknown"
        default: return "\(UIDevice.current.batteryState.stateString) - \(UIDevice.current.batteryLevel * 100.0)%"
        }
    }

    var hardwareDevice: String {
        return Diagnostic.deviceNamesByCode[self.rawHardwareDevice] ?? "Unknown"
    }

    init(address: String, creationMethod: CreationMethod, passphrase: Bool, email: String, issue: String) {
        walletAddress = address
        walletCreationMethod = creationMethod
        walletPassphrase = passphrase
        issueSummary = issue
        emailAddress = email
    }

    init(email: String, issue: String) {
        emailAddress = email
        issueSummary = issue
    }
}
