//
//  CacheManager.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-15.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Cache
import Imaginary
import StellarHub

final class CacheManager {
    static let shared = CacheManager()

    let images = Configuration.imageStorage
    var qrCodes: Storage<Image> = {
        let diskConfig = DiskConfig(name: "QRCodes")
        let memoryConfig = MemoryConfig(expiry: .never)

        do {
            return try Storage<Image>(diskConfig: diskConfig,
                                      memoryConfig: memoryConfig,
                                      transformer: TransformerFactory.forImage())
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private init() { }

    static func cacheAccountQRCode(_ account: StellarAccount) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        let qrCodeOperation = CacheAccountQROperation(accountId: account.accountId)
        queue.addOperation(qrCodeOperation)
    }

    func clearAll() {
        clearShared()
        clearAccountCache()
    }

    func clearShared() {
        try? images.removeAll()
    }

    func clearAccountCache() {
        try? qrCodes.removeAll()
    }
}
