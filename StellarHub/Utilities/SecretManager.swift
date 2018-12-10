//
//  SecretManager.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import KeychainSwift
import stellarsdk

public final class SecretManager: SecretManagerProtocol {
    static let publicSeedKeyFormat = "%@_publicKey"
    static let privateSeedKeyFormat = "%@_privateKey"
    static let secretSeedKeyFormat = "%@_secretSeed"
    static let mnemonicKeyFormat = "%@_mnemonic"
    static let passphraseKeyFormat = "%@_passphrase"

    let accountId: String

    private static func publicKeyKey(for accountId: String) -> String {
        return String(format: SecretManager.publicSeedKeyFormat, accountId)
    }

    private static func privateKeyKey(for accountId: String) -> String {
        return String(format: SecretManager.privateSeedKeyFormat, accountId)
    }

    private static func secretSeedKey(for accountId: String) -> String {
        return String(format: SecretManager.secretSeedKeyFormat, accountId)
    }

    private static func mnemonicKey(for accountId: String) -> String {
        return String(format: SecretManager.mnemonicKeyFormat, accountId)
    }

    private static func passphraseKey(for accountId: String) -> String {
        return String(format: SecretManager.passphraseKeyFormat, accountId)
    }

    var publicKeyKey: String { return SecretManager.publicKeyKey(for: self.accountId) }
    var privateKeyKey: String { return SecretManager.privateKeyKey(for: self.accountId) }
    var secretSeedKey: String { return SecretManager.secretSeedKey(for: self.accountId) }
    var mnemonicKey: String { return SecretManager.mnemonicKey(for: self.accountId) }
    var passphraseKey: String { return SecretManager.passphraseKey(for: self.accountId) }

    init(for account: String) {
        self.accountId = account
    }

    static func hasSecrets(for accountId: String) -> Bool {
        let seedKey = self.secretSeedKey(for: accountId)
        let mnemonicKey = self.mnemonicKey(for: accountId)
        let privateKeyKey = self.privateKeyKey(for: accountId)
        let publicKeyKey = self.publicKeyKey(for: accountId)

        if KeychainSwift().get(seedKey) != nil {
            return true
        } else if KeychainSwift().get(mnemonicKey) != nil {
            return true
        } else if KeychainSwift().getData(privateKeyKey) != nil && KeychainSwift().getData(publicKeyKey) != nil {
            // warning: No mnemonic && no seed set for this account
            return true
        } else {
            return false
        }
    }

    var publicKey: Data? {
        return KeychainSwift().getData(publicKeyKey)
    }

    var privateKey: Data? {
        return KeychainSwift().getData(privateKeyKey)
    }

    var secretSeed: String? {
        return KeychainSwift().get(secretSeedKey)
    }

    var mnemonic: String? {
        return KeychainSwift().get(mnemonicKey)
    }

    var passphrase: String? {
        return KeychainSwift().get(passphraseKey)
    }

    internal func store(keyPair: KeyPair) {
        let pubKey = keyPair.publicKey
        guard let privKey = keyPair.privateKey else { return }

        self.store(pub: pubKey, priv: privKey)
    }

    internal func store(mnemonic: StellarRecoveryMnemonic, passphrase: StellarMnemonicPassphrase? = nil) {
        KeychainSwift().set(mnemonic.string, forKey: mnemonicKey)

        guard let phrase = passphrase?.string else { return }
        KeychainSwift().set(phrase, forKey: passphraseKey)
    }

    internal func store(seed: StellarSeed) {
        KeychainSwift().set(seed.string, forKey: secretSeedKey)
    }

    internal func store(pub: PublicKey, priv: PrivateKey) {
        KeychainSwift().set(Data(bytes: pub.bytes), forKey: publicKeyKey)
        KeychainSwift().set(Data(bytes: priv.bytes), forKey: privateKeyKey)
    }

    internal func erase() {
        KeychainSwift().delete(privateKeyKey)
        KeychainSwift().delete(publicKeyKey)
        KeychainSwift().delete(secretSeedKey)
        KeychainSwift().delete(mnemonicKey)
        KeychainSwift().delete(passphraseKey)
    }
}
