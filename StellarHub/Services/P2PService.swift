//
//  P2PService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-29.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

public final class P2PService: Subservice {
    let core: CoreServiceProtocol

    var p2pQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        return queue
    }()

    internal init(with core: CoreService) {
        self.core = core
    }
}
