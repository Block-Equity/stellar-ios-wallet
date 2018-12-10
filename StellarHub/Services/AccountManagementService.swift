//
//  AccountService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public protocol AccountManagementServiceDelegate: AnyObject {
    func accountUpdated(_ service: AccountManagementService,
                        account: StellarAccount,
                        opts: AccountManagementService.UpdateOptions)
    func accountInactive(_ service: AccountManagementService, account: StellarAccount)
    func paymentUpdate(_ service: AccountManagementService, operation: StellarOperation)
}

/**
 * The `AccountService` is responsible for managing a single Stellar account for the BlockEQ wallet. It controls
 * all communication with the Stellar SDK, and is meant to be a lightweight wrapper for operations concering an account.
 *
 * One service object corresponds to one account, and data for each is independently managed and passed back to the app.
 *
 */
public final class AccountManagementService: AccountManagementServiceProtocol {
    public enum AccountState {
        case inactive
        case initializing
        case active
    }

    static let accountUpdateInterval: TimeInterval = 30

    let core: CoreServiceProtocol

    public internal(set) var account: StellarAccount?

    var state: AccountState = .inactive
    var secretManager: SecretManager?
    var paymentStreamItem: OperationsStreamItem?
    var lastFetch: TimeInterval?
    var timer: Timer?
    var subscribers: MulticastDelegate<AccountManagementServiceDelegate>

    lazy var accountQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }()

    internal init(with core: CoreServiceProtocol) {
        self.core = core
        self.subscribers = MulticastDelegate<AccountManagementServiceDelegate>()
    }

    public func registerForUpdates<T: AccountManagementServiceDelegate>(_ object: T) {
        subscribers.add(delegate: object)
    }

    public func unregisterForUpdates<T: AccountManagementServiceDelegate>(_ object: T) {
        subscribers.remove(delegate: object)
    }

    deinit {
        stopPeriodicUpdates()
    }
}

// MARK: -
// MARK: Account Initialization
extension AccountManagementService {
    // Reloads a AccountService object that's previously been associated with an account by assuming secrets have
    // already been stored for the account.
    public func restore(with address: StellarAddress) throws {
        guard account == nil else { throw FrameworkError.AccountServiceError.alreadyInitialized }

        startup(address: address)
    }

    // Creates a new account with the provided mnemonic
    public func initializeAccount(with mnemonic: StellarRecoveryMnemonic,
                                  passphrase: StellarMnemonicPassphrase?,
                                  index: Int = 0) throws {
        guard account == nil else { throw FrameworkError.AccountServiceError.alreadyInitialized }

        guard let keyPair = try? Wallet.createKeyPair(mnemonic: mnemonic.string,
                                                      passphrase: passphrase?.string,
                                                      index: index) else {
            throw FrameworkError.AccountServiceError.keypairCreation
        }

        self.startup(keyPair: keyPair)
        self.secretManager?.store(mnemonic: mnemonic, passphrase: passphrase)
    }

    // Creates a new account with the provided seed
    public func initializeAccount(with seed: StellarSeed) throws {
        guard account == nil else { throw FrameworkError.AccountServiceError.alreadyInitialized }

        state = .initializing

        guard let keyPair = try? KeyPair(secretSeed: seed.string) else {
            throw FrameworkError.AccountServiceError.keypairCreation
        }

        self.startup(keyPair: keyPair)
        self.secretManager?.store(seed: seed)
    }

    public func migrateAccount(with address: StellarAddress,
                               mnemonicKey: String,
                               seedKey: String,
                               pubKey: String,
                               privKey: String) throws {
        guard account == nil else { throw FrameworkError.AccountServiceError.alreadyInitialized }

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
extension AccountManagementService {
    /// Requests data that's occured between now and the last time data was fetched
    public func update() {
        guard state == .active else {
            return
        }

        guard let account = self.account else { return }

        // Trigger an account update notifying the delegate on the main thread
        self.update(account: account, using: core.sdk) { account, options in
            DispatchQueue.main.async {
                self.lastFetch = Date().timeIntervalSinceReferenceDate

                if options.contains(.inactive) {
                    self.subscribers.invoke(invocation: { $0.accountInactive(self, account: account) })
                } else {
                    self.subscribers.invoke(invocation: { $0.accountUpdated(self, account: account, opts: options) })
                }
            }
        }
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
extension AccountManagementService {
    public func accountMnemonic() -> StellarRecoveryMnemonic? {
        return StellarRecoveryMnemonic(secretManager?.mnemonic)
    }

    public func accountPassphrase() -> StellarMnemonicPassphrase? {
        return StellarMnemonicPassphrase(secretManager?.passphrase)
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

#if DEBUG
extension AccountManagementService {
    /// This method perminantly writes the provided account data to the keychain with no public key. It's used for
    /// debugging purposes when mimicing other accounts.
    ///
    /// - Parameter account: The account string
    public func overrideWithAccount(id accountId: String) {
        self.account = StellarAccount(accountId: accountId)

        let secretManager = SecretManager(for: accountId)
        self.secretManager = secretManager

        if let keyPair = try? KeyPair(accountId: accountId) {
            secretManager.store(keyPair: keyPair)
        }
    }
}
#endif
