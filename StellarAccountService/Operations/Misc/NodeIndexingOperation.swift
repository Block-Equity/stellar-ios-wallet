//
//  NodeIndexingOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-11-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol NodeIndexingDelegate: AnyObject {
    func updatedProgress(_ operation: Operation, fractionCompleted: Double)
}

final class NodeIndexingOperation: Operation {
    private typealias EdgePair = (forward: Edge, reverse: Edge)
    internal typealias OperationType = DataNode<StellarOperation>
    internal typealias EffectType = DataNode<StellarEffect>
    internal typealias TransactionType = DataNode<StellarTransaction>

    let operations: [OperationType]
    let effects: [EffectType]
    let transactions: [TransactionType]

    var edges = Set<Edge>()
    var result = Result<Bool>.failure(NodeIndexingOperationError.notStarted)
    weak var delegate: NodeIndexingDelegate?

    var overallProgress: Progress!
    var effectOperationIdMapProgress: Progress!
    var operationIdMapProgress: Progress!
    var operationTransactionHashMapProgress: Progress!
    var transactionHashProgress: Progress!
    var operationEdgeProgress: Progress!
    var transactionEdgeProgress: Progress!

    private var indexingWasCancelled: Bool {
        guard !isCancelled else {
            result = Result.failure(NodeIndexingOperationError.cancelled)
            return true
        }

        return false
    }

    private var eligibleForIndexing: Bool {
        guard self.effects.count > 0 else {
            result = Result.failure(NodeIndexingOperationError.missingEffects)
            return false
        }

        guard self.operations.count > 0 else {
            result = Result.failure(NodeIndexingOperationError.missingOperations)
            return false
        }

        guard self.transactions.count > 0 else {
            result = Result.failure(NodeIndexingOperationError.missingTransactions)
            return false
        }

        return true
    }

    init(operations: [OperationType], effects: [EffectType], transactions: [TransactionType]) {
        self.operations = operations
        self.effects = effects
        self.transactions = transactions

        print("""
            \nStarting node indexing with:
                \(effects.count) effects
                \(transactions.count) transactions
                \(operations.count) operations\n
            """)

        super.init()

        buildProgressTree()
    }

    override func main() {
        guard !indexingWasCancelled else { return }
        guard eligibleForIndexing else { return }

        let effectOperationIdMap: [String: EffectType] = effects.reduce(into: [:]) { result, node in
            result[node.object().operationId] = node
            effectOperationIdMapProgress.completedUnitCount += 1
        }

        reportProgress()

        guard !indexingWasCancelled else { return }

        let operationIdMap: [String: OperationType] = operations.reduce(into: [:]) { result, node in
            result[node.object().identifier] = node
            operationIdMapProgress.completedUnitCount += 1
        }

        reportProgress()

        guard !indexingWasCancelled else { return }

        let operationTransactionHashMap: [String: OperationType] = operations.reduce(into: [:]) { result, node in
            result[node.object().transactionHash] = node
            operationTransactionHashMapProgress.completedUnitCount += 1
        }

        reportProgress()

        guard !indexingWasCancelled else { return }

        let transactionHashMap: [String: TransactionType] = transactions.reduce(into: [:]) { result, node in
            result[node.object().hash] = node
            transactionHashProgress.completedUnitCount += 1
        }

        reportProgress()

        guard !indexingWasCancelled else { return }

        operationEdgeProgress.totalUnitCount = Int64(operationIdMap.count)
        transactionEdgeProgress.totalUnitCount = Int64(transactionHashMap.count)

        processOperationEdges(operationMap: operationIdMap, effectMap: effectOperationIdMap)

        guard !indexingWasCancelled else { return }

        processTransactionEdges(transactionMap: transactionHashMap, operationMap: operationTransactionHashMap)

        result = Result.success(true)
    }

    private func processOperationEdges(operationMap: [String: NodeIndexingOperation.OperationType],
                                       effectMap: [String: EffectType]) {
        guard !indexingWasCancelled else { return }

        for item in operationMap.enumerated() {
            guard !indexingWasCancelled else { return }

            operationEdgeProgress.completedUnitCount += 1

            reportProgress()

            let key = item.element.key
            guard let effect = effectMap[key], let operation = operationMap[key] else { continue }

            let pair = (forward: Edge(AnyDataNode(effect), AnyDataNode(operation)),
                        reverse: Edge(AnyDataNode(operation), AnyDataNode(effect)))

            self.add(pair)
        }
    }

    private func processTransactionEdges(transactionMap: [String: NodeIndexingOperation.TransactionType],
                                         operationMap: [String: NodeIndexingOperation.OperationType]) {
        guard !indexingWasCancelled else { return }

        for item in transactionMap.enumerated() {
            guard !indexingWasCancelled else { return }

            transactionEdgeProgress.completedUnitCount += 1

            reportProgress()

            let key = item.element.key
            guard let operation = operationMap[key], let transaction = transactionMap[key] else { continue }

            let pair = EdgePair(forward: Edge(AnyDataNode(transaction), AnyDataNode(operation)),
                                reverse: Edge(AnyDataNode(operation), AnyDataNode(transaction)))

            self.add(pair)
        }
    }

    private func add(_ edges: EdgePair) {
        self.edges.insert(edges.forward)
        self.edges.insert(edges.reverse)
    }

    private func buildProgressTree() {
        let totalEffects = Int64(effects.count)
        let totalOps = Int64(operations.count)
        let totalTxns = Int64(transactions.count)

        overallProgress = Progress(totalUnitCount: 10)
        operationEdgeProgress = Progress(totalUnitCount: 0)
        transactionEdgeProgress = Progress(totalUnitCount: 0)
        effectOperationIdMapProgress = Progress(totalUnitCount: totalEffects)
        operationIdMapProgress = Progress(totalUnitCount: totalOps)
        operationTransactionHashMapProgress = Progress(totalUnitCount: totalOps)
        transactionHashProgress = Progress(totalUnitCount: totalTxns)

        overallProgress.addChild(operationEdgeProgress, withPendingUnitCount: 3)
        overallProgress.addChild(transactionEdgeProgress, withPendingUnitCount: 3)
        overallProgress.addChild(effectOperationIdMapProgress, withPendingUnitCount: 1)
        overallProgress.addChild(operationIdMapProgress, withPendingUnitCount: 1)
        overallProgress.addChild(operationTransactionHashMapProgress, withPendingUnitCount: 1)
        overallProgress.addChild(transactionHashProgress, withPendingUnitCount: 1)
    }

    private func reportProgress() {
        let amount = self.overallProgress.fractionCompleted
//        let completed = self.overallProgress.completedUnitCount
//        let total = self.overallProgress.totalUnitCount
//        print("completed: \(amount) currentUnits: \(completed) totalUnits: \(total)")
        self.delegate?.updatedProgress(self, fractionCompleted: amount)
    }
}

enum NodeIndexingOperationError: Error {
    case notStarted
    case missingTransactions
    case missingOperations
    case missingEffects
    case cancelled
}

extension NodeIndexingOperationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notStarted: return "The indexing operation hasn't begun."
        case .missingTransactions: return "The transaction list hasn't been fetched and is required to begin indexing."
        case .missingOperations: return "The operation list hasn't been fetched and is required to begin indexing."
        case .missingEffects: return "The effect list hasn't been fetched and is required to begin indexing."
        case .cancelled: return "The operation was cancelled by the indexing service."
        }
    }
}
