//
//  StellarAccountService.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public protocol StellarAccountServiceDelegate: AnyObject {
    func accountUpdated(_ service: StellarAccountService, account: StellarAccount, opts: StellarAccount.UpdateOptions)
    func accountInactive(_ service: StellarAccountService, account: StellarAccount)
    func paymentUpdate(_ service: StellarAccountService, operation: StellarOperation)
}

/**
 * The `StellarAccountService` is responsible for managing a single Stellar account for the BlockEQ wallet. It controls
 * all communication with the Stellar SDK, and is meant to be a lightweight wrapper for operations concering an account.
 *
 * One service object corresponds to one account, and data for each is independently managed and passed back to the app.
 *
 */
public final class StellarAccountService: StellarAccountServiceProtocol {
    public enum ServiceError: Error {
        case nonExistentAccount
        case alreadyInitialized
        case keypairCreation
        case initializationFailure
        case notInitialized
        case secureItemPurge
        case migrationFailed
    }

    public enum AccountState {
        case inactive
        case initializing
        case active
    }

    static let accountUpdateInterval: TimeInterval = 30

    let core: CoreService

    public weak var delegate: StellarAccountServiceDelegate?
    public internal(set) var account: StellarAccount?

    var state: AccountState = .inactive
    var secretManager: SecretManager?
    var paymentStreamItem: OperationsStreamItem?
    var lastFetch: TimeInterval?
    var timer: Timer?

    internal init(with core: CoreService) {
        self.core = core
    }

    deinit {
        stopPeriodicUpdates()
    }
}

// MARK: -
// MARK: Account Initialization
extension StellarAccountService {
    // Reloads a StellarAccountService object that's previously been associated with an account by assuming secrets have
    // already been stored for the account.
    public func restore(with address: StellarAddress) throws {
        guard account == nil else { throw ServiceError.alreadyInitialized }

        startup(address: address)
    }

    // Creates a new account with the provided mnemonic
    public func initializeAccount(with mnemonic: StellarRecoveryMnemonic, index: Int = 0) throws {
        guard account == nil else { throw ServiceError.alreadyInitialized }

        guard let keyPair = try? Wallet.createKeyPair(mnemonic: mnemonic.string, passphrase: nil, index: index) else {
            throw ServiceError.keypairCreation
        }

        self.startup(keyPair: keyPair)
        self.secretManager?.store(mnemonic: mnemonic)
    }

    // Creates a new account with the provided seed
    public func initializeAccount(with seed: StellarSeed) throws {
        guard account == nil else { throw ServiceError.alreadyInitialized }

        state = .initializing

        guard let keyPair = try? KeyPair(secretSeed: seed.string) else {
            throw ServiceError.keypairCreation
        }

        self.startup(keyPair: keyPair)
        self.secretManager?.store(seed: seed)
    }

    public func migrateAccount(with address: StellarAddress,
                               mnemonicKey: String,
                               seedKey: String,
                               pubKey: String,
                               privKey: String) throws {
        guard account == nil else { throw ServiceError.alreadyInitialized }

        let migrator = StellarAccountMigrator(address: address,
                                              mnemonicKey: mnemonicKey,
                                              seedKey: seedKey,
                                              pubKey: pubKey,
                                              privKey: privKey)

        try migrator.beginMigration()
    }
}

// MARK: -
// MARK: Account Updating
extension StellarAccountService {
    /// Requests data that's occured between now and the last time data was fetched
    public func update() {
        guard state == .active else {
            return
        }

        // Trigger an account update notifying the delegate on the main thread
        account?.update(using: core.sdk, completion: { account, options in
            DispatchQueue.main.async {
                self.lastFetch = Date().timeIntervalSinceReferenceDate

                if options.contains(.inactive) {
                    self.delegate?.accountInactive(self, account: account)
                } else {
                    self.delegate?.accountUpdated(self, account: account, opts: options)
                }
            }
        })
    }

    public func startPeriodicUpdates() {
        startPeriodicTimer()
        startPaymentStream()
    }

    public func stopPeriodicUpdates() {
        if let streamItem = self.paymentStreamItem {
            streamItem.closeStream()
            paymentStreamItem = nil
        }

        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}

// MARK: -
// MARK: Data Management
extension StellarAccountService {
    public func accountMnemonic() -> StellarRecoveryMnemonic? {
        return StellarRecoveryMnemonic(secretManager?.mnemonic)
    }

    public func accountSecretSeed() -> StellarSeed? {
        return StellarSeed(secretManager?.secretSeed)
    }

    // Removes all data corresponding to the account managed by this account service
    public func clear() {
        stopPeriodicUpdates()

        account = nil
        lastFetch = nil

        if let secrets = self.secretManager {
            secrets.erase()
            secretManager = nil
        }

        state = .inactive
    }
}
