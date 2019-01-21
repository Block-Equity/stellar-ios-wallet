//
//  IndexingService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

public protocol IndexableStellarObject: Codable {
    var nodePrefix: String { get }
    var objectIdentifier: String { get }
}

extension StellarEffect: IndexableStellarObject {
    public var nodePrefix: String { return "enode" }
    public var objectIdentifier: String { return self.identifier }
}

extension StellarTransaction: IndexableStellarObject {
    public var nodePrefix: String { return "tnode" }
    public var objectIdentifier: String { return self.identifier }
}

extension StellarOperation: IndexableStellarObject {
    public var nodePrefix: String { return "onode" }
    public var objectIdentifier: String { return self.identifier }
}

/// The IndexingService maps account effects, transactions and operations together by correlating objects
/// that have common keys so that we can minimize the number of required network calls to the Horizon API.
///
/// The following holds true:
///
/// **Effect** <-> OperationId <-> **Operation** <-> TransactionHash <-> **Transaction**
public final class IndexingService: IndexingServiceProtocol {
    let core: CoreServiceProtocol
    let graph: StellarDataGraph
    var lastAccountIndexHash: Int = 0

    internal lazy var indexQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1

        return queue
    }()

    public var progress: Progress? {
        if let indexingOperation = indexQueue.operations.first as? NodeIndexingOperation {
            return indexingOperation.overallProgress
        }

        return nil
    }

    public weak var delegate: IndexingServiceDelegate?

    internal init(with core: CoreServiceProtocol) {
        self.core = core
        self.graph = StellarDataGraph()
    }

    /// Updates the existing index with new incoming operations, transactions or effects.
    ///
    /// The update method will never remove items from its self since the Stellar blockchain is immutable.
    internal func updateIndex() {
        guard !indexQueue.isSuspended else { return }

        if let existingIndexOperation = indexQueue.operations.first as? NodeIndexingOperation,
            existingIndexOperation.isExecuting || !existingIndexOperation.isReady {
            return
        }

        let indexOperation = NodeIndexingOperation(operations: graph.operationNodes,
                                                   effects: graph.effectNodes,
                                                   transactions: graph.transactionNodes)
        indexOperation.delegate = self

        graph.edges.formUnion(indexOperation.edges)

        indexOperation.completionBlock = { [unowned self] in
            DispatchQueue.main.async {
                if indexOperation.result.isSuccess {
                    self.delegate?.finishedIndexing(self)
                } else {
                    self.delegate?.errorIndexing(self, error: indexOperation.result.error)
                }
            }
        }

        indexQueue.addOperation(indexOperation)
    }

    /// Removes the previously built index and starts again.
    public func rebuildIndex() {
        graph.clearEdges()
        updateIndex()
    }

    /// Immediately halts the indexing process.
    public func haltIndexing() {
        indexQueue.cancelAllOperations()
    }

    /// Removes all objects from the index and does not begin to rebuild it.
    public func reset() {
        haltIndexing()
        graph.clear()
    }

    /// Prevents the execution of further indexing operations.
    func pause() {
        indexQueue.isSuspended = true
    }

    /// Resumes the execution of further indexing operations.
    func resume() {
        indexQueue.isSuspended = false
    }

    /**
     This method returns the first found object of type `Out` provided a concreted object of type `In`.
     - Parameter start: The specific indexable object to start the search from.

     In order for an object to be returned, there must be a path from `A -> B -> C`, where:
     - `In` corresponds to the object type that represents `A`
     - `Out` corresponds to the object type that represents `C`
     */
    public func relatedObject<In: IndexableStellarObject, Out: IndexableStellarObject>(startingAt object: In) -> Out? {
        guard In.self != Out.self else { return nil }

        let dataNode = DataNode<In>(object)
        let anyNode = AnyDataNode(dataNode)

        if let finalNode = self.traverse(for: anyNode, edgeList: graph.edges)?.erasedObject as? Out {
            return finalNode
        }

        return nil
    }

    /**
     Recursive method which performs a graph traversal through type erased nodes, progressivly narrowing the list of
     possible edges to compare until a matching one is found.

     - Parameters:
       - currentNode: The node we're currently traversing from.
       - edgeList: A list of edges to.

     - Returns: `nil` if there isn't a path to the provided node, or an optional type erased node representing the type
     of object we're searching for.
     */
    func traverse(for currentNode: AnyDataNode, edgeList: Set<Edge>) -> AnyDataNode? {
        let currentNodeType = currentNode._storage.nodeType
        let currentNodeObject = currentNode.erasedObject
        let incidentEdges = graph.incidentEdges(for: currentNode, in: edgeList)

        // If there is no incident edges for the current object, it isn't connected to anything further
        guard incidentEdges.count > 0 else {
            return currentNode
        }

        // We can optimize our search for nodes that don't match
        let filteredEdges: Set<Edge> = edgeList.filter { edge -> Bool in
            let first = edge.first
            let second = edge.second
            let firstNodeIsntInputNode = first.erasedObject.objectIdentifier != currentNodeObject.objectIdentifier
            let firstNodeIsDifferentType = first._storage.nodeType != currentNodeType
            let secondNodeIsDifferentType = second._storage.nodeType != currentNodeType
            return firstNodeIsntInputNode && firstNodeIsDifferentType && secondNodeIsDifferentType
        }

        var possibleNodes: [AnyDataNode?] = []

        for edge in incidentEdges.enumerated() {
            let destinationNode = edge.element.second
            let subSearch = self.traverse(for: destinationNode, edgeList: filteredEdges)
            possibleNodes.append(subSearch)
        }

        return possibleNodes.compactMap { $0 }.first
    }
}

extension StellarDataGraph {
    var operationNodes: [DataNode<StellarOperation>] {
        return nodes.values.compactMap { $0.node() }
    }

    var effectNodes: [DataNode<StellarEffect>] {
        return nodes.values.compactMap { $0.node() }
    }

    var transactionNodes: [DataNode<StellarTransaction>] {
        return nodes.values.compactMap { $0.node() }
    }
}

extension IndexingService: AccountUpdateServiceDelegate {
    public func firstAccountUpdate(_ service: AccountUpdateService, account: StellarAccount) {
    }

    public func accountUpdated(_ service: AccountUpdateService,
                               account: StellarAccount,
                               options: AccountUpdateService.UpdateOptions) {
        graph.add(account.effects)
        graph.add(account.transactions)
        graph.add(account.operations)

        if lastAccountIndexHash != account.hashValue {
            lastAccountIndexHash = account.hashValue
            updateIndex()
        }
    }
}

extension IndexingService: NodeIndexingDelegate {
    func updatedProgress(_ operation: NodeIndexingOperation, fractionCompleted: Double) {
        graph.edges.formUnion(operation.edges)

        DispatchQueue.main.async {
            self.delegate?.updatedProgress(self, completed: fractionCompleted)
        }
    }
}
