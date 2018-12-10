//
//  StellarDataGraph.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-11-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

internal protocol AnyDataNodeProtocol {
    var nodeType: IndexableStellarObject.Type { get }
    var erasedObject: IndexableStellarObject { get }
    var nodeIdentifier: String { get }
}

internal protocol DataNodeProtocol: AnyDataNodeProtocol {
    associatedtype DataType: IndexableStellarObject
    func object() -> DataType
}

extension AnyDataNodeProtocol where Self: DataNodeProtocol {
    var nodeType: IndexableStellarObject.Type {
        return DataType.self
    }
}

extension AnyDataNodeProtocol where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.nodeIdentifier == rhs.nodeIdentifier && lhs.nodeType == rhs.nodeType
    }
}

extension DataNodeProtocol where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.nodeIdentifier == rhs.nodeIdentifier && lhs.nodeType == rhs.nodeType
    }
}

//swiftlint:disable identifier_name
internal struct AnyDataNode {
    var _storage: AnyDataNodeProtocol

    init<DataType: AnyDataNodeProtocol>(_ node: DataType) {
        _storage = node
    }

    var nodeIdentifier: String {
        return _storage.nodeIdentifier
    }

    var erasedObject: IndexableStellarObject {
        return _storage.erasedObject
    }

    func object<DataType: IndexableStellarObject>() -> DataType? {
        if DataType.self == _storage.nodeType, let unerasedObject = erasedObject as? DataType {
            return unerasedObject
        }

        return nil
    }

    func node<DataType: IndexableStellarObject>() -> DataNode<DataType>? {
        if let obj: DataType = self.object() {
            return DataNode<DataType>(obj)
        }

        return nil
    }
}

extension AnyDataNode: Hashable {
    static func == (lhs: AnyDataNode, rhs: AnyDataNode) -> Bool {
        return lhs.nodeIdentifier == rhs.nodeIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.nodeIdentifier)
    }
}
//swiftlint:enable force_cast identifier_name

internal final class DataNode<DataType: IndexableStellarObject>: DataNodeProtocol {
    var data: DataType
    var erasedObject: IndexableStellarObject { return data }

    var nodeIdentifier: String {
        return "\(data.nodePrefix):\(erasedObject.objectIdentifier)"
    }

    init(_ data: DataType) {
        self.data = data
    }

    func object() -> DataType {
        return data
    }
}

// MARK: - Edge
internal struct Edge: Hashable {
    var first: AnyDataNode
    var second: AnyDataNode

    init(_ first: AnyDataNode, _ second: AnyDataNode) {
        self.first = first
        self.second = second
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(first.nodeIdentifier)
        hasher.combine(second.nodeIdentifier)
    }
}

// MARK: - StellarDataGraph
/// Undirected disjoint graph that can be used to represent connections between objects in a `StellarAccount`.
internal final class StellarDataGraph: Codable {
    internal var nodes: [AnyHashable: AnyDataNode] = [:]
    internal var edges: Set<Edge> = []

    internal init() {

    }

    internal init(from decoder: Decoder) throws {
        // Eventually deserialize from disk
    }

    internal func encode(to encoder: Encoder) throws {
        // Eventually deserialize to disk
    }

    /// Inserts the conforming node types into the node list.
    ///
    /// Because each node is stored in a dictionary, inserting duplicates has no adverse effects.
    ///
    /// - Parameter nodes: The mapped nodes created from Stellar objects.
    func add<NodeType: IndexableStellarObject>(_ objects: [NodeType]) {
        objects.forEach { data in
            let dataNode = DataNode<NodeType>(data)
            let anyNode = AnyDataNode(dataNode)
            add(anyNode)
        }
    }

    /// Inserts a node that has already been type erased.
    ///
    /// - Parameter node: A type erased data node
    internal func add(_ node: AnyDataNode) {
        nodes[node.nodeIdentifier] = node
    }

    /// Only removes edges from the graph.
    func clearEdges() {
        edges.removeAll(keepingCapacity: true)
    }

    /// Removes all edges and nodes from the graph.
    func clear() {
        edges.removeAll(keepingCapacity: true)
        nodes.removeAll(keepingCapacity: true)
    }

    func incidentEdges(for node: AnyDataNode, in list: Set<Edge>?) -> Set<Edge> {
        var edgeList: Set<Edge>
        edgeList = list ?? self.edges
        return edgeList.filter { $0.first == node }
    }

    func debug() {
        print("NODE LIST\n---------")
        for node in self.nodes.values {
            if let txn: DataNode<StellarTransaction> = node.node() {
                print(txn)
            } else if let opr: DataNode<StellarOperation> = node.node() {
                print(opr)
            } else if let eff: DataNode<StellarEffect> = node.node() {
                print(eff)
            }
        }

        print("\nEDGE LIST\n---------")
        for edge in self.edges.enumerated() {
            print("\(edge.element.first.nodeIdentifier) -> \(edge.element.second.nodeIdentifier)")
        }
    }
}
