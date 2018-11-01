//
//  StellarCoreService.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-26.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class StellarCoreService: CoreService {
    let sdk: StellarSDK
    let api: StellarConfig.HorizonAPI

    var services: [Subservice] {
        return [accountService, tradeService]
    }

    internal var secretManager: SecretManagerProtocol? {
        return accountService.secretManager
    }

    public var accountService: StellarAccountService!
    public var tradeService: StellarTradeService!
    public var indexingService: StellarIndexingService!

    public init(with horizonAPI: StellarConfig.HorizonAPI) {
        api = horizonAPI
        sdk = StellarSDK(withHorizonUrl: horizonAPI.urlString)

        let accService = StellarAccountService(with: self)
        let trService = StellarTradeService(with: self)
        let idxService = StellarIndexingService(with: self)

        self.accountService = accService
        self.tradeService = trService
        self.indexingService = idxService

        accService.registerForUpdates(idxService)
    }
}

extension StellarCoreService {
    internal var walletKeyPair: KeyPair? {
        guard let secretManager = self.secretManager,
            let privateKeyData = secretManager.privateKey,
            let publicKeyData = secretManager.publicKey else {
                return nil
        }

        let publicBytes: [UInt8] = [UInt8](publicKeyData)
        let privateBytes: [UInt8] = [UInt8](privateKeyData)

        return try? KeyPair(publicKey: PublicKey(publicBytes), privateKey: PrivateKey(privateBytes))
    }
}
