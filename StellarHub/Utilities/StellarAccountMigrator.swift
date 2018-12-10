//
//  StellarAccountMigrator.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import KeychainSwift

internal final class StellarAccountMigrator {
    let address: StellarAddress
    let oldMnemonicKey: String
    let oldSeedKey: String
    let oldPrivkKey: String
    let oldPubkKey: String
    let backupKey: String

    public init(address: StellarAddress, mnemonicKey: String, seedKey: String, pubKey: String, privKey: String) {
        self.address = address
        backupKey = String(format: "%@_backup", address.string)
        oldMnemonicKey = mnemonicKey
        oldSeedKey = seedKey
        oldPubkKey = pubKey
        oldPrivkKey = privKey
    }

    public func beginMigration() throws {
        backupOldData()

        var requireSeed = false
        var requireMnemonic = false
        let secretManager = SecretManager(for: self.address.string)

        if let mnemonicString = KeychainSwift().get(oldMnemonicKey),
            let mnemonic = StellarRecoveryMnemonic(mnemonicString) {
            secretManager.store(mnemonic: mnemonic)
        } else {
            // WARN: no mnemonic detected - we require a secret key now to complete
            requireSeed = true
        }

        if let seedString = KeychainSwift().get(oldSeedKey), let seed = StellarSeed(seedString) {
            secretManager.store(seed: seed)
        } else {
            // WARN: no seed detected - we require a mnemonic now to complete
            requireMnemonic = true
        }

        if requireMnemonic && requireSeed {
            // ERROR: Can't migrate account data
            throw FrameworkError.AccountServiceError.migrationFailed
        }

        if let pubData = KeychainSwift().getData(oldPubkKey), let privData = KeychainSwift().getData(oldPrivkKey) {
            let pKey = try PublicKey(pubData.bytes)
            let qKey = try PrivateKey(privData.bytes)
            secretManager.store(pub: pKey, priv: qKey)
        } else {
            throw FrameworkError.AccountServiceError.migrationFailed
        }
    }

    private func backupOldData() {
        let oldSecrets: [String: Any?] = [
            oldMnemonicKey: KeychainSwift().get(oldMnemonicKey),
            oldSeedKey: KeychainSwift().get(oldSeedKey),
            oldPubkKey: KeychainSwift().getData(oldPubkKey),
            oldPrivkKey: KeychainSwift().getData(oldPrivkKey)
        ]

        KeychainSwift().set(NSKeyedArchiver.archivedData(withRootObject: oldSecrets), forKey: backupKey)
    }
}
