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

class KeychainHelper: NSObject {
    static let mnemonicKeyValue = "mnemonic"
    static let accountIdKeyValue = "accountId"
    static let publicKeyValue = "publicKey"
    static let privateKeyValue = "privateKey"
    static let pinKeyValue = "pin"
    static let isFreshInstall = "isFreshInstall"
    
    public static func save(mnemonic: String) {
        KeychainSwift().set(mnemonic, forKey: mnemonicKeyValue)
    }
    
    public static func save(accountId: String) {
        KeychainSwift().set(accountId, forKey: accountIdKeyValue)
    }
    
    public static func save(publicKey: Data) {
        KeychainSwift().set(publicKey, forKey: publicKeyValue)
    }
    
    public static func save(privateKey: Data) {
        KeychainSwift().set(privateKey, forKey: privateKeyValue)
    }
    
    public static func save(pin: String) {
        KeychainSwift().set(pin, forKey: pinKeyValue)
    }
    
    public static func getMnemonic() -> String? {
        return KeychainSwift().get(mnemonicKeyValue)
    }
    
    public static func getAccountId() -> String? {
        return KeychainSwift().get(accountIdKeyValue)
    }
    
    public static func getPublicKey() -> Data? {
        return KeychainSwift().getData(publicKeyValue)
    }
    
    public static func getPrivateKey() -> Data? {
        return KeychainSwift().getData(privateKeyValue)
    }
    
    public static func getPin() -> String? {
        return KeychainSwift().get(pinKeyValue)
    }
    
    public static func isExistingInstance() -> Bool {
        if !UserDefaults.standard.bool(forKey: isFreshInstall) {
            UserDefaults.standard.set(true, forKey: isFreshInstall)
            return false
        }
        return true
    }
    
    public static func clearAll() {
        KeychainSwift().clear()
    }
}
