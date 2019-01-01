//
//  ChainableOperationPair.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol ChainableOperation: AnyObject {
    associatedtype InDataType
    associatedtype OutDataType

    var inData: InDataType? { get set }
    var outData: OutDataType? { get }
}

/**
 * The ChainedOperationPair class is responsible for connecting two dependent operations together; by feeding the
 * output of the first operation into the input of the second operation.
 *
 * It glues the two operations together by using a BlockOperation that sets state on the second operation, and then
 * inserting it into the middle of the dependency chain.
 */
final class ChainedOperationPair<FirstType: ChainableOperation, SecondType: ChainableOperation> where
    FirstType.OutDataType == SecondType.InDataType,
    FirstType: Operation,
    SecondType: Operation {
    private var firstOperation: FirstType
    private var secondOperation: SecondType
    private let adapter: BlockOperation

    var operationChain: [Operation] {
        return [firstOperation, adapter, secondOperation]
    }

    init(first: FirstType, second: SecondType) {
        firstOperation = first
        secondOperation = second

        self.adapter = BlockOperation(block: { [unowned firstOperation, unowned secondOperation] in
            if firstOperation.isCancelled {
                secondOperation.cancel()
                return
            } else {
                secondOperation.inData = firstOperation.outData
            }
        })

        secondOperation.addDependency(adapter)
        adapter.addDependency(firstOperation)
    }

    func cancelAll() {
        self.firstOperation.cancel()
        self.secondOperation.cancel()
        self.adapter.cancel()
    }
}
