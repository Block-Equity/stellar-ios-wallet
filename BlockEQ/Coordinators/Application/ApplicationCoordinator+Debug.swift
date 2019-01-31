//
//  ApplicationCoordinator+Debug.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

extension ApplicationCoordinator: IndexingViewControllerDelegate {
    func requestedCancelIndexing(_ viewController: IndexingViewController) {
        core.indexingService.haltIndexing()
        indexingViewController?.update(with: nil, error: nil)
    }

    func requestedRestartIndexing(_ viewController: IndexingViewController) {
        guard let account = core.accountService.account else { return }

        core.indexingService.rebuildIndex(for: account)
        indexingViewController?.update(with: 0, error: nil)
    }
}
