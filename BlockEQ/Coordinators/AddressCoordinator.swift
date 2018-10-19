//
//  AddressResolver.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

final class AddressResolver {
    enum AddressType {
        case exchange
        case contact
    }

    static let shared = AddressResolver()

    private var mappedExchanges: [String: Exchange] = [:]
    private var mappedContacts: [String: LocalContact] = [:]

    private init() {
        loadExchangeData()

        let contacts: [LocalContact] = []
        mappedContacts = contacts.reduce(into: [:]) { map, contact in
            map[contact.address] = contact
        }
    }

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

    private func loadExchangeData() {
        let decoder = JSONDecoder()
        guard let path = Bundle.main.path(forResource: "exchanges", ofType: "json") else { return }

        if let localExchangeData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let decodedExchanges = try? decoder.decode([Exchange].self, from: localExchangeData) {
            mappedExchanges = decodedExchanges.reduce(into: [:]) { map, exchange in
                map[exchange.address] = exchange
            }
        }
    }
}
