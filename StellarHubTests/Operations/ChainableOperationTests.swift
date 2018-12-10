//
//  ChainableOperationTests.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-12-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import XCTest
@testable import StellarHub

fileprivate class SuperTestOperation: Operation {
    var cancelCalled: Bool = false
    var operationWasRun: Bool = false

    override func cancel() {
        cancelCalled = true
        super.cancel()
    }

    override func main() {
        operationWasRun = true
        super.main()
    }
}

final fileprivate class TestOperation1: SuperTestOperation, ChainableOperation {
    typealias InDataType = Int
    typealias OutDataType = Bool

    var inData: Int?
    var outData: Bool?
}

final fileprivate class TestOperation2: SuperTestOperation, ChainableOperation {
    typealias InDataType = Bool
    typealias OutDataType = Int

    var inData: Bool?
    var outData: Int?
}

class ChainableOperationTests: XCTestCase {
    let queue = OperationQueue()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOperationChainReturnsOperations() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)

        XCTAssertEqual(chainableOperation.operationChain.count, 3)
    }

    func testCancelCallsCancelOnAllOperations() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)
        chainableOperation.cancelAll()

        guard chainableOperation.operationChain.count == 3, let adapterOp = chainableOperation.operationChain.last else {
            XCTFail("Chainable operation requires 3 operations to be valid.")
            return
        }

        XCTAssertTrue(firstOp.cancelCalled)
        XCTAssertTrue(secondOp.cancelCalled)
        XCTAssertTrue(adapterOp.isCancelled)
    }

    func testAllOperationsRun() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)
        queue.addOperations(chainableOperation.operationChain, waitUntilFinished: true)

        XCTAssertTrue(firstOp.operationWasRun)
        XCTAssertTrue(secondOp.operationWasRun)
    }

    func testNoOperationsRunIfAllCancelled() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)
        chainableOperation.cancelAll()

        queue.addOperations(chainableOperation.operationChain, waitUntilFinished: true)

        XCTAssertFalse(firstOp.operationWasRun)
        XCTAssertFalse(secondOp.operationWasRun)
    }

    func testSecondOperationIsNotCalledIfFirstCancelled() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        firstOp.cancel()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)
        queue.addOperations(chainableOperation.operationChain, waitUntilFinished: true)

        XCTAssertFalse(firstOp.operationWasRun)
        XCTAssertFalse(secondOp.operationWasRun)
    }

    func testInputOfFirstChainableOperationIsPassedToSecondChainableOperation() {
        let firstOp = TestOperation1()
        let secondOp = TestOperation2()

        let chainableOperation = ChainedOperationPair(first: firstOp, second: secondOp)
        queue.addOperations(chainableOperation.operationChain, waitUntilFinished: true)

        XCTAssertEqual(firstOp.outData, secondOp.inData)
    }
}
