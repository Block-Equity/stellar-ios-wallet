//
//  StreamServiceTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-12-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
import stellarsdk
@testable import StellarHub

final class MockStreamListener: AnyStreamListener {
    var status: StreamService.StreamStatus = .closed
    var calledToggle: Bool = false
    var calledEnable: Bool = false
    var calledDisable: Bool = false
    var calledClose: Bool = false

    func toggle() throws {
        calledToggle = true
    }

    func enable() throws {
        calledEnable = true
    }

    func disable() throws {
        calledDisable = true
    }

    func close() {
        calledClose = true
    }
}

class StreamServiceTests: XCTestCase {
    var streamService: StreamService!

    override func setUp() {
        super.setUp()

        let core = stubCoreService()
        self.streamService = StreamService(with: core)
    }

    override func tearDown() {
        self.streamService = nil
        super.tearDown()
    }

    func subscribe(stream: StreamService.StreamType) throws {
        let accountId = streamService.core.walletKeyPair!.accountId
        try streamService.subscribe(to: stream, account: StellarAccount(accountId: accountId))
    }

    func unsubscribe(stream: StreamService.StreamType) throws {
        try streamService.unsubscribe(from: stream)
    }

    func testSupportedStreamsReturnsCorrectArray() {
        let options: [StreamService.StreamType] = [.effects, .operations, .transactions]
        XCTAssertEqual(StreamService.StreamType.supportedStreams, options)
    }

    func testSubscribingToEffectStreamSetsStreamObject() {
        XCTAssertNil(streamService.effectsStream)
        try? subscribe(stream: .effects)
        XCTAssertNotNil(streamService.effectsStream)
    }

    func testResubscribingToEffectStreamDoesNothing() {
        try? subscribe(stream: .effects)
        let stream1 = streamService.effectsStream

        try? subscribe(stream: .effects)
        let stream2 = streamService.effectsStream

        XCTAssertNotNil(stream1)
        XCTAssertTrue(stream1 === stream2)
    }

    func testSubscribingToOperationsStreamSetsStreamObject() {
        XCTAssertNil(streamService.operationsStream)
        try? subscribe(stream: .operations)
        XCTAssertNotNil(streamService.operationsStream)
    }

    func testResubscribingToOperationsStreamDoesNothing() {
        try? subscribe(stream: .operations)
        let stream1 = streamService.operationsStream

        try? subscribe(stream: .operations)
        let stream2 = streamService.operationsStream

        XCTAssertNotNil(stream1)
        XCTAssertTrue(stream1 === stream2)
    }

    func testSubscribingtoTransactionsStreamSetsStreamObject() {
        XCTAssertNil(streamService.transactionsStream)
        try? subscribe(stream: .transactions)
        XCTAssertNotNil(streamService.transactionsStream)
    }

    func testResubscribingToTransactionsStreamDoesNothing() {
        try? subscribe(stream: .transactions)
        let stream1 = streamService.transactionsStream

        try? subscribe(stream: .transactions)
        let stream2 = streamService.transactionsStream

        XCTAssertNotNil(stream1)
        XCTAssertTrue(stream1 === stream2)
    }

    func testSubscribingToUnsupportedStreamThrowsError() {
        let requiredError = FrameworkError.StreamServiceError.unsupportedStreamType

        XCTAssertThrowsError(try subscribe(stream: .ledgers), "Must throw an unsupported stream error") { error in
            guard error as! FrameworkError.StreamServiceError == requiredError else {
                XCTFail("Error should be an unsupportedStreamError")
                return
            }
        }
    }

    func testUnsubscribingFromEffectsStreamClosesAndNilsStreamObject() {
        try? subscribe(stream: .effects)
        XCTAssertNotNil(streamService.effectsStream)
        try? unsubscribe(stream: .effects)
        XCTAssertNil(streamService.effectsStream)
    }

    func testUnsubscribingFromOperationsStreamClosesAndNilsStreamObject() {
        try? subscribe(stream: .operations)
        XCTAssertNotNil(streamService.operationsStream)
        try? unsubscribe(stream: .operations)
        XCTAssertNil(streamService.operationsStream)
    }

    func testUnsubscribingFromTransactionsStreamClosesAndNilsStreamObject() {
        try? subscribe(stream: .transactions)
        XCTAssertNotNil(streamService.transactionsStream)
        try? unsubscribe(stream: .transactions)
        XCTAssertNil(streamService.transactionsStream)
    }

    func testUnsubscribingFromUnsupportedStreamThrowsError() {
        let requiredError = FrameworkError.StreamServiceError.unsupportedStreamType

        XCTAssertThrowsError(try unsubscribe(stream: .ledgers), "Must throw an unsupported stream error") { error in
            guard error as! FrameworkError.StreamServiceError == requiredError else {
                XCTFail("Error should be an unsupportedStreamError")
                return
            }
        }
    }

    func testSubscribingToAllStreamsEnablesSupportedStreams() {
        let accountId = streamService.core.walletKeyPair!.accountId
        streamService.subscribeAll(account: StellarAccount(accountId: accountId))
        XCTAssertNotNil(streamService.effectsStream)
        XCTAssertNotNil(streamService.operationsStream)
        XCTAssertNotNil(streamService.transactionsStream)
    }

    func testUnsubscribingFromAllStreamsRemovesSupportedStreams() {
        let accountId = streamService.core.walletKeyPair!.accountId
        streamService.subscribeAll(account: StellarAccount(accountId: accountId))
        XCTAssertNotNil(streamService.effectsStream)
        XCTAssertNotNil(streamService.operationsStream)
        XCTAssertNotNil(streamService.transactionsStream)

        streamService.unsubscribeAll()
        XCTAssertNil(streamService.effectsStream)
        XCTAssertNil(streamService.operationsStream)
        XCTAssertNil(streamService.transactionsStream)
    }

    func testTogglingStreams() {
        let mockEffects = MockStreamListener()
        let mockOps = MockStreamListener()
        let mockTxns = MockStreamListener()

        streamService.effectsStream = mockEffects
        streamService.operationsStream = mockOps
        streamService.transactionsStream = mockTxns

        try? streamService.toggle(stream: .effects)
        XCTAssertTrue(mockEffects.calledToggle)

        try? streamService.toggle(stream: .operations)
        XCTAssertTrue(mockOps.calledToggle)

        try? streamService.toggle(stream: .transactions)
        XCTAssertTrue(mockTxns.calledToggle)
    }

    func testTogglingUnsupportedStreamThrowsError() {
        let requiredError = FrameworkError.StreamServiceError.unsupportedStreamType

        XCTAssertThrowsError(try streamService.toggle(stream: .ledgers),
                             "Must throw an unsupported stream error") { error in
            guard error as! FrameworkError.StreamServiceError == requiredError else {
                XCTFail("Error should be an unsupportedStreamError")
                return
            }
        }
    }

    func testAccountSwitchedImplementationSubscribesToAllStreams() {
        let managementService = AccountManagementService(with: streamService.core)

        let account = StellarAccount(accountId: streamService.core.walletKeyPair!.accountId)
        streamService.subscribeAll(account: account)

        let stream1 = streamService.effectsStream
        XCTAssertNotNil(stream1)

        let stream2 = streamService.operationsStream
        XCTAssertNotNil(stream2)

        let stream3 = streamService.transactionsStream
        XCTAssertNotNil(stream3)

        streamService.accountSwitched(managementService, account: account)
        XCTAssertNotNil(streamService.effectsStream)
        XCTAssertNotNil(streamService.operationsStream)
        XCTAssertNotNil(streamService.transactionsStream)

        XCTAssertFalse(stream1 === streamService.effectsStream)
        XCTAssertFalse(stream2 === streamService.operationsStream)
        XCTAssertFalse(stream3 === streamService.transactionsStream)
    }
}
