//
//  ApplicationCoordinator+AccountExtensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-22.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

// MARK: - AccountManagementServiceDelegate
extension ApplicationCoordinator: AccountManagementServiceDelegate {
    func accountSwitched(_ service: AccountManagementService, account: StellarAccount) {
    }
}

// MARK: - AccountUpdateServiceDelegate
extension ApplicationCoordinator: AccountUpdateServiceDelegate {
    func firstAccountUpdate(_ service: AccountUpdateService, account: StellarAccount) {
        service.accountUpdateInterval = AccountUpdateService.longUpdateInterval
        core?.streamService.subscribeAll(account: account)
    }

    func accountUpdated(_ service: AccountUpdateService,
                        account: StellarAccount,
                        options: AccountUpdateService.UpdateOptions) {
        if options.contains(.effects) || options.contains(.account) {
            walletViewController.updated(account: account)
            KeychainHelper.setHasFetchedData()
        }

        tradingCoordinator?.updated(account: account)
        balanceViewController?.updated(account: account)
    }
}

// MARK: - StreamServiceDelegate
extension ApplicationCoordinator: StreamServiceDelegate {
    func streamError(service: StreamService, stream: StreamService.StreamType, error: FrameworkError) {
        if error.errorCategory == .stellar {
            try? service.unsubscribe(from: stream)
        }
    }

    func receivedObjects(stream: StreamService.StreamType) {
        core?.updateService.update()
    }
}
