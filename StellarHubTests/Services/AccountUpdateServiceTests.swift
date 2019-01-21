//
//  AccountUpdateServiceTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-12-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
import stellarsdk
@testable import StellarHub

final class TestAccountUpdateServiceDelegate: AccountUpdateServiceDelegate {
    var callbackAccount: StellarAccount?
    var callbackOptions: AccountUpdateService.UpdateOptions?
    let asyncUpdateExpectation = XCTestExpectation(description: "Update is called")

    func firstAccountUpdate(_ service: AccountUpdateService, account: StellarAccount) {
    }

    func accountUpdated(_ service: AccountUpdateService,
                        account: StellarAccount,
                        options: AccountUpdateService.UpdateOptions) {
        asyncUpdateExpectation.fulfill()
        self.callbackAccount = account
        self.callbackOptions = options
    }
}

class AccountUpdateServiceTests: XCTestCase {
    var accountService: AccountUpdateService!

    override func setUp() {
        super.setUp()

        let core = stubCoreService()
        self.accountService = AccountUpdateService(with: core)
    }

    override func tearDown() {
        self.accountService = nil
        super.tearDown()
    }

    func testThatUpdateOptionsCanBeInitialized() {
        let options = AccountUpdateService.UpdateOptions(rawValue: 2)
        XCTAssertEqual(options, .account)
    }

    func testThatUpdateServiceReturnsTheSameOperationQueueEveryTime() {
        let firstOperationQueue = accountService.updateQueue
        let secondOperationQueue = accountService.updateQueue
        XCTAssertEqual(firstOperationQueue, secondOperationQueue)
    }

    func testThatCallingUpdateDoesNothingWithNoAccount() {
        let queue = accountService.updateQueue
        accountService.update()

        XCTAssertEqual(queue.operations.count, 0)
    }

    func testThatCallingUpdateEnqueuesAllUpdateOperations() {
        let accountQueue = accountService.updateQueue
        let accountId = accountService.core.walletKeyPair!.accountId

        accountService.account = StellarAccount(accountId: accountId)
        accountService.update()

        XCTAssertEqual(accountQueue.operations.count, 5)
    }

    func testAccountSwitchedImplementationSetsAccount() {
        let accountId = accountService.core.walletKeyPair!.accountId
        let account = StellarAccount(accountId: accountId)
        let managementService = AccountManagementService(with: accountService.core)
        accountService.accountSwitched(managementService, account: account)
        XCTAssertEqual(accountService.account, account)
    }

    func testThatStartingPeriodicUpdatesCreatesATimer() {
        XCTAssertNil(accountService.timer)
        accountService.startPeriodicUpdates()
        XCTAssertNotNil(accountService.timer)
    }

    func testThatStoppingPeriodicUpdatesRemovesTheTimer() {
        XCTAssertNil(accountService.timer)
        accountService.startPeriodicUpdates()
        XCTAssertNotNil(accountService.timer)
        accountService.stopPeriodicUpdates()
    }

    func testRegisterAndUnregisterSubscribers() {
        let testDelegate = TestAccountUpdateServiceDelegate()
        accountService.registerForUpdates(testDelegate)
        XCTAssertEqual(accountService.subscribers.subscriberCount, 1)

        accountService.unregisterForUpdates(testDelegate)
        XCTAssertEqual(accountService.subscribers.subscriberCount, 0)
    }

    func testTimerBlockCallsUpdateAndNotifiesSubscribers() {
        let testDelegate = TestAccountUpdateServiceDelegate()
        accountService.registerForUpdates(testDelegate)
        XCTAssertEqual(accountService.subscribers.subscriberCount, 1)

        let accountId = accountService.core.walletKeyPair!.accountId
        accountService.account = StellarAccount(accountId: accountId)

        accountService.startPeriodicUpdates()
        accountService.timer?.fire()
        accountService.stopPeriodicUpdates()

        wait(for: [testDelegate.asyncUpdateExpectation], timeout: 1)
    }
}
