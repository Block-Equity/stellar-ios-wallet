//
//  KeychainHelper.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import KeychainSwift
import stellarsdk

final class KeychainHelper {
    static let mnemonicKey = "mnemonic"
    static let secretSeedKey = "secretSeed"
    static let accountIdKey = "accountId"
    static let hasFetchedDataKey = "fetchedData"
    static let publicSeedKey = "publicKey"
    static let privateSeedKey = "privateKey"
    static let pinKey = "pin"
    static let isFreshInstallKey = "isFreshInstall"
    static let walletDiagnosticKey = "walletDiagnostic"

    public static func save(pin: String) {
        KeychainSwift().set(pin, forKey: pinKey)
    }

    public static func save(accountId: String) {
        KeychainSwift().set(accountId, forKey: accountIdKey)
    }

    public static var mnemonic: String? {
        return KeychainSwift().get(mnemonicKey)
    }

    public static var secretSeed: String? {
        return KeychainSwift().get(secretSeedKey)
    }

    public static var accountId: String? {
        return KeychainSwift().get(accountIdKey)
    }

    public static var publicKey: Data? {
        return KeychainSwift().getData(publicSeedKey)
    }

    public static var privateKey: Data? {
        return KeychainSwift().getData(privateSeedKey)
    }

    public static var pin: String? {
        return KeychainSwift().get(pinKey)
    }

    public static var hasPin: Bool {
        return !(KeychainSwift().get(pinKey)?.isEmpty ?? true)
    }

    public static var canMigrateToNewFormat: Bool {
        let hasAccount = self.accountId != nil
        let hasKeys = self.publicKey != nil && self.privateKey != nil
        let hasRecovery = self.secretSeed != nil || self.mnemonic != nil
        return hasAccount && hasKeys && hasRecovery
    }

    public static var hasFetchedData: Bool {
        return UserDefaults.standard.bool(forKey: hasFetchedDataKey)
    }

    public static func setHasFetchedData() {
        UserDefaults.standard.set(true, forKey: hasFetchedDataKey)
    }

    public static var hasExistingInstance: Bool {
        return UserDefaults.standard.bool(forKey: isFreshInstallKey)
    }

    public static func setExistingInstance() {
        UserDefaults.standard.set(true, forKey: isFreshInstallKey)
    }

    public static func setDiagnostic(_ walletDiagnostic: WalletDiagnostic) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(walletDiagnostic) {
            KeychainSwift().set(data, forKey: walletDiagnosticKey)
        }
    }

    public static var walletDiagnostic: WalletDiagnostic? {
        let jsonDecoder = JSONDecoder()

        guard let data = KeychainSwift().getData(walletDiagnosticKey),
            let diagnostic = try? jsonDecoder.decode(WalletDiagnostic.self, from: data) else {
                return nil
        }

        return diagnostic
    }

    public static func clearAll() {
        UserDefaults.standard.set(false, forKey: isFreshInstallKey)
        UserDefaults.standard.set(false, forKey: hasFetchedDataKey)
        self.clearStellarSecrets()
        KeychainSwift().delete(accountIdKey)
        KeychainSwift().delete(pinKey)
        KeychainSwift().delete(walletDiagnosticKey)
    }

    public static func clearStellarSecrets() {
        KeychainSwift().delete(mnemonicKey)
        KeychainSwift().delete(secretSeedKey)
        KeychainSwift().delete(publicSeedKey)
        KeychainSwift().delete(privateSeedKey)
    }

    /// Validates the pin stored in the keychain with the input pin provided.
    ///
    /// - Parameters:
    ///   - pin: The input pin to be verified.
    ///   - comparePin: Optionally, you may provide your own pin to compare.
    /// - Returns: A boolean value indicating if the two pins match, or false otherwise.
    /// - Important: The pin check will always fail on an empty string.
    public static func check(pin: String, comparePin: String? = KeychainHelper.pin) -> Bool {
        if pin == comparePin && !pin.isEmpty {
            return true
        }

        return false
    }
}

// MARK: -
// MARK: StellarSDK.Wallet
extension KeychainHelper {
    public static var walletKeyPair: KeyPair? {
        guard let privateKeyData = KeychainHelper.privateKey,
            let publicKeyData = KeychainHelper.publicKey else {
                return nil
        }

        let publicBytes: [UInt8] = [UInt8](publicKeyData)
        let privateBytes: [UInt8] = [UInt8](privateKeyData)

        return try? KeyPair(publicKey: PublicKey(publicBytes), privateKey: PrivateKey(privateBytes))
    }

    public static func issuerKeyPair(accountId: String) -> KeyPair? {
        guard let pubKey = try? PublicKey(accountId: accountId) else {
            return nil
        }

        return KeyPair(publicKey: pubKey, privateKey: nil)
    }
}
