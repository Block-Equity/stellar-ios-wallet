//
//  StellarHubTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

var effect: StellarEffect!

class IndexingServiceTests: XCTestCase {
    var accountService: StubAccountService!
    var service: IndexingService!
    var account: StellarAccount!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func stubIndexingService() {
        let seed = "SBCATWZ7RYZK2VY4D5RLVJQGSRLEJXM4PTAA5ZZLIQIGBGQITV6YRAKJ"
        let mnemonic = "a mnemonic for testing"
        let stubKeyPair = try! KeyPair(secretSeed: seed)

        let pubData = Data(bytes: stubKeyPair.publicKey.bytes)
        let privData = Data(bytes: stubKeyPair.privateKey!.bytes)

        let stubSecretManager = StubSecretManager(publicKey: pubData,
                                                  privateKey: privData,
                                                  secretSeed: seed,
                                                  mnemonic: mnemonic)

        let env = StellarConfig.HorizonAPI.custom("localhost")
        let sdk = StellarSDK(withHorizonUrl: env.urlString)
        let core = StubCoreService(sdk: sdk, api: env, secretManager: stubSecretManager, keyPair: stubKeyPair)

        let indexingService = IndexingService(with: core)
        let stubAccount = StellarAccount(accountId: stubKeyPair.accountId)
//        let accountService = StubAccountService(core: core, stubAccount: stubAccount, stubSecretManager: stubSecretManager, subscribers: MulticastDelegate<AccountServiceDelegate>(), state: .active)

//        self.accountService = accountService
        self.service = indexingService
        self.account = stubAccount
    }

    func testTest() {
        self.stubIndexingService()

        let response: AccountResponse = JSONLoader.decodableJSON(name: "account_response")
        let account = StellarAccount(response)

        let txnResponse: [TransactionResponse] = JSONLoader.decodableJSON(name: "account_transactions")
        let stellarTransactions: [StellarTransaction] = txnResponse.map { StellarTransaction($0) }
        account.mappedTransactions = stellarTransactions.reduce(into: [:]) { map, transaction in
            map[transaction.identifier] = transaction
        }

        let effectResponse: [EffectResponse] = JSONLoader.decodableJSON(name: "account_effects")
        let stellarEffects: [StellarEffect] = effectResponse.map { StellarEffect($0) }
        account.mappedEffects = stellarEffects.reduce(into: [:]) { map, effect in
            map[effect.identifier] = effect
        }

        let operationResponse: [OperationResponse] = JSONLoader.decodableJSON(name: "account_operations")
        let stellarOperations: [StellarOperation] = operationResponse.map { StellarOperation($0) }
        account.mappedOperations = stellarOperations.reduce(into: [:]) { map, operation in
            map[operation.identifier] = operation
        }

        effect = stellarEffects.first(where: { effect -> Bool in
            effect.identifier == "0086676421467996161-0000000001"
        })

//        self.service.accountUpdated(accountService, account: account, opts: .account)

        let delegate = MockIndexingServiceDelegate()
//        let expectation = XCTestExpectation(description: "finishes")

        self.service.delegate = delegate
//        wait(for: [expectation], timeout: 1000)
    }
}

final class MockIndexingServiceDelegate: IndexingServiceDelegate {
    func updatedProgress(_ service: IndexingService, completed: Double) {

    }

    func finishedIndexing(_ service: IndexingService) {
        let _: StellarTransaction? = service.relatedObject(startingAt: effect)
    }

    func errorIndexing(_ service: IndexingService, error: Error?) {

    }
}
