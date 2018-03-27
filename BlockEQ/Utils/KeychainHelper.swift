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
    static let mnemonicKey = "mnemonic"
    static let accountIdKey = "accountId"
    static let publicSeedKey = "publicKey"
    static let privateSeedKey = "privateKey"
    static let pinKey = "pin"
    static let isFreshInstallKey = "isFreshInstall"
    static let isEnteringAppKey = "isEnteringApp"
    static let isSendingPaymentKey = "isEnteringApp"
    
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
    
    public static func setPinWhenEnteringApp(shouldSet: Bool) {
        UserDefaults.standard.set(shouldSet, forKey: isEnteringAppKey)
        UserDefaults.standard.synchronize()
    }
    
    public static func setPinWhenSendingPayment(shouldSet: Bool) {
        UserDefaults.standard.set(shouldSet, forKey: isSendingPaymentKey)
        UserDefaults.standard.synchronize()
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
    
    public static func isExistingInstance() -> Bool {
        if !UserDefaults.standard.bool(forKey: isFreshInstallKey) {
            UserDefaults.standard.set(true, forKey: isFreshInstallKey)
            UserDefaults.standard.synchronize()
            return false
        }
        return true
    }
    
    public static func checkPinWhenEnteringApp() -> Bool {
        return UserDefaults.standard.bool(forKey: isEnteringAppKey)
    }
    
    public static func checkPinWhenSendingPayment() -> Bool {
        return UserDefaults.standard.bool(forKey: isSendingPaymentKey)
    }
    
    public static func clearAll() {
        KeychainSwift().clear()
        
        UserDefaults.standard.set(false, forKey: isEnteringAppKey)
        UserDefaults.standard.set(false, forKey: isSendingPaymentKey)
        UserDefaults.standard.synchronize()
    }
}
