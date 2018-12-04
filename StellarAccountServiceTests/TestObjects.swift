//
//  TestObjects.swift
//  StellarAccountServiceTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

@testable import StellarAccountService
import stellarsdk

// MARK: - Stubs
final class StubStellarCoreService: CoreService {
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

final class StubStellarAccountService: StellarAccountServiceProtocol {
    let core: CoreService

    var subscribers: MulticastDelegate<StellarAccountServiceDelegate>

    var state: StellarAccountService.AccountState

    var secretManager: SecretManager?

    var account: StellarAccount?

    init(core: CoreService,
         stubAccount: StellarAccount,
         stubSecretManager: SecretManager,
         subscribers: MulticastDelegate<StellarAccountServiceDelegate>,
         state: StellarAccountService.AccountState) {
        self.core = core
        self.secretManager = stubSecretManager
        self.account = stubAccount
        self.subscribers = subscribers
        self.state = state
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
    var errorCompletion: (ServiceErrorCompletion)?

    func setInflation(destination: StellarAddress) {
        setInflationAddress = destination
        setInflationCompletion?(destination)
    }

    func failed(error: FrameworkError) {
        self.error = error
        self.errorCompletion?(error)
    }
}
