//
//  StellarHubOperationTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub
import stellarsdk

class AccountServiceOperationTests: XCTestCase {
    let testSeed = "SBCATWZ7RYZK2VY4D5RLVJQGSRLEJXM4PTAA5ZZLIQIGBGQITV6YRAKJ"
    var stubAccount: StellarAccount!
    var service: AccountManagementService!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        self.stubAccount = nil
        self.service = nil
    }

    func setupStubAccount() {
        let stubKeyPair = try! KeyPair(secretSeed: testSeed)
        self.stubAccount = StellarAccount(accountId: stubKeyPair.accountId)
    }

    func setupService(with seed: String = "this wont work") {
        var stubSecretManager: StubSecretManager?
        var keyPair: KeyPair?
        if let stubKeyPair = try? KeyPair(secretSeed: seed) {
            let pubData = Data(bytes: stubKeyPair.publicKey.bytes)
            let privData = Data(bytes: stubKeyPair.privateKey!.bytes)

            stubSecretManager = StubSecretManager(publicKey: pubData,
                                                      privateKey: privData,
                                                      secretSeed: seed,
                                                      mnemonic: "a mnemonic for testing")

            keyPair = stubKeyPair
        }

        let env = StellarConfig.HorizonAPI.custom("localhost")
        let sdk = StellarSDK(withHorizonUrl: env.urlString)
        let core = StubCoreService(sdk: sdk, api: env, secretManager: stubSecretManager, keyPair: keyPair)

        self.service = AccountManagementService(with: core)
    }

    func setupServiceAccount() {
        let keyPair = service.core.walletKeyPair!
        let stubAccount = StellarAccount(accountId: keyPair.accountId)
        self.service.account = stubAccount
        self.stubAccount = stubAccount
    }

    func testAccountQueueHasHighPriority() {
        setupService()
        XCTAssertEqual(service.accountQueue.qualityOfService, .userInitiated)
    }

    func testSetInflationCallsFailureWhenMissingRequiredData() {
        setupService()
        setupStubAccount()
        let mockDelegate = MockInflationResponseDelegate()
        let newInflationAddress = StellarAddress("GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")!
        self.service.setInflationDestination(account: stubAccount, address: newInflationAddress, delegate: mockDelegate)
        XCTAssertEqual(mockDelegate.error, FrameworkError(error: FrameworkError.AccountServiceError.missingKeypair))
    }

    func testSetInflationEnqueuesCorrectOperations() {
        setupService(with: self.testSeed)
        setupServiceAccount()

        let queue = self.service.accountQueue
        queue.isSuspended = true

        let mockDelegate = MockInflationResponseDelegate()
        let newInflationAddress = StellarAddress("GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")!
        self.service.setInflationDestination(account: stubAccount, address: newInflationAddress, delegate: mockDelegate)

        XCTAssertEqual(queue, self.service.accountQueue)
        XCTAssertEqual(queue.operationCount, 3)
    }
}
