//
//  TestObjects.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

@testable import StellarHub
import stellarsdk

// MARK: - Stubs
final class StubCoreService: CoreServiceProtocol {
    var sdk: StellarSDK

    var api: StellarConfig.HorizonAPI

    var secretManager: SecretManagerProtocol?

    var walletKeyPair: KeyPair?

    var services: [Subservice] {
        return []
    }

    init(sdk: StellarSDK, api: StellarConfig.HorizonAPI, secretManager: SecretManagerProtocol?, keyPair: KeyPair?) {
        self.sdk = sdk
        self.api = api
        self.secretManager = secretManager
        self.walletKeyPair = keyPair
    }
}

final class StubAccountService: AccountManagementServiceProtocol {
    let core: CoreServiceProtocol

    var subscribers: MulticastDelegate<AccountManagementServiceDelegate>

    var state: AccountManagementService.AccountState

    var secretManager: SecretManager?

    var account: StellarAccount?

    init(core: CoreService,
         stubAccount: StellarAccount,
         stubSecretManager: SecretManager,
         subscribers: MulticastDelegate<AccountManagementServiceDelegate>,
         state: AccountManagementService.AccountState) {
        self.core = core
        self.secretManager = stubSecretManager
        self.account = stubAccount
        self.subscribers = subscribers
        self.state = state
    }

    func reset() {
    }
}

final class StubSecretManager: SecretManagerProtocol {
    var publicKeyKey: String { return "publickeykey" }

    var privateKeyKey: String { return "privatekeykey" }

    var secretSeedKey: String { return "secretseedkey" }

    var mnemonicKey: String { return "mnemonickey" }

    var publicKey: Data?

    var privateKey: Data?

    var secretSeed: String?

    var mnemonic: String?

    init(publicKey: Data, privateKey: Data, secretSeed: String, mnemonic: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.secretSeed = secretSeed
        self.mnemonic = mnemonic
    }
}

// MARK: - Mocks
final class MockInflationResponseDelegate: SetInflationResponseDelegate {
    var setInflationAddress: StellarAddress?
    var error: FrameworkError?

    var setInflationCompletion: ((StellarAddress) -> Void)?
    var clearInflationCompletion: (() -> Void)?
    var errorCompletion: (ServiceErrorCompletion)?

    func setInflation(destination: StellarAddress) {
        setInflationAddress = destination
        setInflationCompletion?(destination)
    }

    func clearInflation() {
        setInflationAddress = nil
        clearInflationCompletion?()
    }

    func inflationFailed(error: FrameworkError) {
        self.error = error
        self.errorCompletion?(error)
    }
}
