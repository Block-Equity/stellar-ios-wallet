//
//  NodeIndexingOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-11-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class NodeIndexingOperation: Operation {
    private typealias EdgePair = (forward: Edge, reverse: Edge)
    internal typealias OperationType = DataNode<StellarOperation>
    internal typealias EffectType = DataNode<StellarEffect>
    internal typealias TransactionType = DataNode<StellarTransaction>

    let progress: Progress
    let operations: [OperationType]
    let effects: [EffectType]
    let transactions: [TransactionType]

    var edges = Set<Edge>()

    init(operations: [OperationType], effects: [EffectType], transactions: [TransactionType]) {
        self.operations = operations
        self.effects = effects
        self.transactions = transactions

        let totalCount = operations.count * 3 + transactions.count * 2 + effects.count
        progress = Progress(totalUnitCount: Int64(totalCount))

        super.init()
    }

    override func main() {
        guard !isCancelled else { return }

        let effectOperationIdMap: [String: EffectType] = effects.reduce(into: [:]) { result, node in
            result[node.object().operationId] = node
            progress.completedUnitCount += 1
        }

        guard !isCancelled else { return }

        let operationIdMap: [String: OperationType] = operations.reduce(into: [:]) { result, node in
            result[node.object().identifier] = node
            progress.completedUnitCount += 1
        }

        guard !isCancelled else { return }

        let operationTransactionHashMap: [String: OperationType] = operations.reduce(into: [:]) { result, node in
            result[node.object().transactionHash] = node
            progress.completedUnitCount += 1
        }

        guard !isCancelled else { return }

        let transactionHashMap: [String: TransactionType] = transactions.reduce(into: [:]) { result, node in
            result[node.object().hash] = node
            progress.completedUnitCount += 1
        }

        for item in operationIdMap.enumerated() {
            guard !isCancelled else { return }

            progress.completedUnitCount += 1

            let key = item.element.key
            guard let effect = effectOperationIdMap[key],
                let operation = operationIdMap[key] else { continue }

            let pair = (forward: Edge(AnyDataNode(effect), AnyDataNode(operation)),
                        reverse: Edge(AnyDataNode(operation), AnyDataNode(effect)))

            self.add(pair)
        }

        for item in transactionHashMap.enumerated() {
            guard !isCancelled else { return }

            progress.completedUnitCount += 1

            let key = item.element.key
            guard let operation = operationTransactionHashMap[key],
                let transaction = transactionHashMap[key] else { continue }

            let pair = EdgePair(forward: Edge(AnyDataNode(transaction), AnyDataNode(operation)),
                                reverse: Edge(AnyDataNode(operation), AnyDataNode(transaction)))

            self.add(pair)
        }
    }

    private func add(_ edges: EdgePair) {
        self.edges.insert(edges.forward)
        self.edges.insert(edges.reverse)
    }
}
