//
//  StellarAccountOperationsTests.swift
//  StellarAccountServiceTests
//
//  Created by Nick DiZazzo on 2018-11-02.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarAccountService
import stellarsdk

class StellarAccountOperationTests: XCTestCase {
    var stubAccount: StellarAccount!
    var service: StellarAccountService!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        self.stubAccount = nil
        self.service = nil
    }

    func stubTestAccount() {
        let seed = "SBCATWZ7RYZK2VY4D5RLVJQGSRLEJXM4PTAA5ZZLIQIGBGQITV6YRAKJ"
        let stubKeyPair = try! KeyPair(secretSeed: seed)
        self.stubAccount = StellarAccount(accountId: stubKeyPair.accountId)
    }

    func stubAccountService() {
        let seed = "SBCATWZ7RYZK2VY4D5RLVJQGSRLEJXM4PTAA5ZZLIQIGBGQITV6YRAKJ"
        let mnemonic = "a mnemonic for testing"
        let stubKeyPair = try! KeyPair(secretSeed: seed)

        let pubData = Data(bytes: stubKeyPair.publicKey.bytes)
        let privData = Data(bytes: stubKeyPair.privateKey!.bytes)

        let stubSecretManager = StubSecretManager(publicKey: pubData,
                                                  privateKey: privData,
                                                  secretSeed: seed,
                                                  mnemonic: mnemonic)

        let env = StellarConfig.HorizonAPI.local
        let sdk = StellarSDK(withHorizonUrl: env.urlString)
        let core = StubStellarCoreService(sdk: sdk, api: env, secretManager: stubSecretManager, keyPair: stubKeyPair)

        let accountService = StellarAccountService(with: core)
        let stubAccount = StellarAccount(accountId: stubKeyPair.accountId)

        accountService.account = stubAccount
        stubAccount.service = accountService

        self.service = accountService
        self.stubAccount = stubAccount
    }

    func testSetInflationCallsFailureWhenMissingRequiredData() {
        self.stubTestAccount()
        let mockDelegate = MockInflationResponseDelegate()
        let newInflationAddress = StellarAddress("GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")!
        self.stubAccount.setInflationDestination(address: newInflationAddress, delegate: mockDelegate)
        XCTAssertEqual(mockDelegate.error, StellarAccountService.ServiceError.nonExistentAccount)
    }

    func testSetInflationEnqueuesCorrectOperations() {
        self.stubAccountService()

        let queue = self.service.account!.accountQueue
        queue.isSuspended = true

        let mockDelegate = MockInflationResponseDelegate()
        let newInflationAddress = StellarAddress("GDUFDDGP6B6VLXC2Z62UYW34VOHHQFL7PXCGWQRLWZXYNJGER3F2QRTZ")!
        self.stubAccount.setInflationDestination(address: newInflationAddress, delegate: mockDelegate)

        XCTAssertEqual(self.stubAccount.accountQueue, self.service.account!.accountQueue)

        XCTAssertEqual(queue.operationCount, 3)
    }
}
