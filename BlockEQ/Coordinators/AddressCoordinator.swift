//
//  AddressResolver.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

final class AddressResolver {
    enum AddressType {
        case exchange
        case contact
    }

    static let shared = AddressResolver()
    private var mappedExchanges: [String: Exchange] = [:]
    private var mappedContacts: [String: LocalContact] = [:]

    static func lookup(address: StellarAddress) -> AddressType {
        return .exchange
    }

    static func resolve(address: StellarAddress) -> LocalContact? {
        let type = lookup(address: address)
        guard type == .contact else { return nil }

        if let contact = shared.mappedContacts[address.string] {
            return contact
        }

        return nil
    }

    static func resolve(address: StellarAddress) -> Exchange? {
        let type = lookup(address: address)
        guard type == .exchange else { return nil }

        if let exchange = shared.mappedExchanges[address.string] {
            return exchange
        }

        return nil
    }

    private func mapContactData(with list: [LocalContact]) {
        mappedContacts = list.reduce(into: [:]) { map, contact in
            map[contact.address] = contact
        }
    }

    private func mapExchangeData(with list: [Exchange]) {
        mappedExchanges = list.reduce(into: [:]) { map, exchange in
            map[exchange.address] = exchange
        }
    }

    private func loadExchangeData() {
        let decoder = JSONDecoder()
        guard let path = Bundle.main.path(forResource: "exchanges", ofType: "json") else { return }

        if let localExchangeData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let decodedExchanges = try? decoder.decode([Exchange].self, from: localExchangeData) {
            self.mapExchangeData(with: decodedExchanges)
        }
    }

    public static func fetchExchangeData() {
        let fetchOperation = FetchExchangesOperation(completion: { exchangeList in
            self.shared.mapExchangeData(with: exchangeList)
        }, failure: { error in
            print("WARNING: Failed to refresh exchange list, defaulting to local copy. (\(error))")
            self.shared.loadExchangeData()
        })

        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        operationQueue.addOperation(fetchOperation)
    }
}
