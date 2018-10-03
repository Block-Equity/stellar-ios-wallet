//
//  AutoFillHelper.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol AutoFillProvider: AnyObject {
    func store(server: CFString, account: CFString, password: CFString?, completion: AutoFillHelper.SaveCallback?)
    func retrieve(server: CFString, account: CFString, completion: @escaping AutoFillHelper.FetchCallback)
}

final class AutoFillHelper {
    typealias SaveCallback = (Error?) -> Void
    typealias FetchCallback = ([[String: String]]?, Error?) -> Void
    typealias AutoFillData = (server: CFString, account: CFString, password: CFString?)

    static var provider: AutoFillProvider?

    public static func save(secret: String, completion: SaveCallback?) {
        let data = self.formatAutoFillData(prefix: "SECRET_SEED_PREFIX".localized(), password: secret)
        self.provider?.store(server: data.server,
                             account: data.account,
                             password: data.password,
                             completion: completion)
    }

    public static func save(mnemonic: String, completion: SaveCallback?) {
        let data = self.formatAutoFillData(prefix: "MNEMONIC_PREFIX".localized(), password: mnemonic)
        self.provider?.store(server: data.server,
                             account: data.account,
                             password: data.password,
                             completion: completion)
    }

    public static func fetch(prefix: String?, completion: @escaping FetchCallback) {
        let data = self.formatAutoFillData(prefix: prefix)
        self.provider?.retrieve(server: data.server, account: data.account, completion: completion)
    }

    internal static func formatAutoFillData(prefix: String? = nil, password: String? = nil) -> AutoFillData {
        let server = "blockeq.com" as CFString
        let keychainAccount = (KeychainHelper.accountId ?? "BLOCKEQ_WALLET".localized()) as CFString
        let cfPassword = password as CFString?

        var account = keychainAccount as CFString
        if let prefix = prefix {
            account = "\(prefix) \(account)" as CFString
        }

        return (server, account, cfPassword)
    }
}
