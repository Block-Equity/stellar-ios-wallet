//
//  CoreService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-26.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public final class CoreService: CoreServiceProtocol {
    let sdk: StellarSDK
    let api: StellarConfig.HorizonAPI

    var services: [Subservice] {
        return [accountService, updateService, indexingService, streamService, tradeService]
    }

    internal var secretManager: SecretManagerProtocol? {
        return accountService.secretManager
    }

    public var accountService: AccountManagementService!
    public var tradeService: TradeService!
    public var indexingService: IndexingService!
    public var streamService: StreamService!
    public var updateService: AccountUpdateService!

    public init(with horizonAPI: StellarConfig.HorizonAPI) {
        api = horizonAPI
        sdk = StellarSDK(withHorizonUrl: horizonAPI.urlString)

        let accService = AccountManagementService(with: self)
        let trService = TradeService(with: self)
        let idxService = IndexingService(with: self)
        let streamService = StreamService(with: self)
        let updateService = AccountUpdateService(with: self)

        self.accountService = accService
        self.tradeService = trService
        self.indexingService = idxService
        self.streamService = streamService
        self.updateService = updateService

        start()
    }

    func start() {
        // Register the services to be notified when the account data is updated
        updateService.registerForUpdates(indexingService)

        // Register the services to be notified when the current account is changed
        accountService.registerForUpdates(streamService)
        accountService.registerForUpdates(updateService)
    }

    public func stopSubservices() {
        services.forEach { $0.reset() }
    }
}

extension CoreService {
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
