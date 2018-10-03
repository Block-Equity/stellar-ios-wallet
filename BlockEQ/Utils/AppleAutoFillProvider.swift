//
//  AppleAutoFillProvider.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AppleAutoFillProvider: AutoFillProvider {
    func store(server: CFString, account: CFString, password: CFString?, completion: AutoFillHelper.SaveCallback?) {
        SecAddSharedWebCredential(server, account, password) { error in
            DispatchQueue.main.async { completion?(error as Error?) }
        }
    }

    func retrieve(server: CFString, account: CFString, completion: @escaping AutoFillHelper.FetchCallback) {
        SecRequestSharedWebCredential(server, account) { data, error in
            if let items = data as? [[String: String]] {
                DispatchQueue.main.async { completion(items, nil) }
            } else {
                DispatchQueue.main.async { completion(nil, error as Error?) }
            }
        }
    }
}
