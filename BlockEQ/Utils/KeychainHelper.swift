//
//  KeychainHelper.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import KeychainSwift
import stellarsdk
import UIKit
import Foundation

final class KeychainHelper {
    static let mnemonicKey = "mnemonic"
    static let accountIdKey = "accountId"
    static let publicSeedKey = "publicKey"
    static let privateSeedKey = "privateKey"
    static let pinKey = "pin"
    static let isFreshInstallKey = "isFreshInstall"

    public static func save(mnemonic: String) {
        KeychainSwift().set(mnemonic, forKey: mnemonicKey)
    }
    
    public static func save(accountId: String) {
        KeychainSwift().set(accountId, forKey: accountIdKey)
    }
    
    public static func save(publicKey: Data) {
        KeychainSwift().set(publicKey, forKey: publicSeedKey)
    }
    
    public static func save(privateKey: Data) {
        KeychainSwift().set(privateKey, forKey: privateSeedKey)
    }
    
    public static func save(pin: String) {
        KeychainSwift().set(pin, forKey: pinKey)
    }
    
    public static func getMnemonic() -> String? {
        return KeychainSwift().get(mnemonicKey)
    }
    
    public static func getAccountId() -> String? {
        return KeychainSwift().get(accountIdKey)
    }
    
    public static func getPublicKey() -> Data? {
        return KeychainSwift().getData(publicSeedKey)
    }
    
    public static func getPrivateKey() -> Data? {
        return KeychainSwift().getData(privateSeedKey)
    }
    
    public static func getPin() -> String? {
        return KeychainSwift().get(pinKey)
    }
    
    public static func hasPin() -> Bool {
        return !(KeychainSwift().get(pinKey)?.isEmpty ?? true)
    }
    
    public static func isExistingInstance() -> Bool {
        return UserDefaults.standard.bool(forKey: isFreshInstallKey)
    }
    
    public static func setExistingInstance() {
        UserDefaults.standard.set(true, forKey: isFreshInstallKey)
    }

    public static func clearAll() {
        UserDefaults.standard.set(false, forKey: isFreshInstallKey)
        KeychainSwift().clear()
    }

    /// Validates the pin stored in the keychain with the input pin provided.
    ///
    /// - Parameters:
    ///   - pin: The input pin to be verified.
    ///   - comparePin: Optionally, you may provide your own pin to compare.
    /// - Returns: A boolean value indicating if the two pins match, or false otherwise.
    /// - Important: The pin check will always fail on an empty string.
    public static func check(pin: String, comparePin: String? = getPin()) -> Bool {
        if pin == comparePin && !pin.isEmpty {
            return true
        }

        return false
    }
}
