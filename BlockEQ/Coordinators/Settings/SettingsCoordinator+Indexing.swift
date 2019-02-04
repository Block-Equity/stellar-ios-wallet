//
//  SettingsCoordinator+Indexing.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-02-05.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

extension SettingsCoordinator {
    func presentIndexingStatus() {
        let indexVC = IndexingViewController()
        indexVC.delegate = self

        indexingViewController = indexVC
        indexVC.update(with: nil, error: nil)

        navWrapper.present(indexVC, animated: true)
    }
}

extension SettingsCoordinator: IndexingServiceDelegate {
    func finishedIndexing(_ service: IndexingService) {
        print("Indexing finished!")
        indexingViewController?.update(with: 1, error: nil)
    }

    func errorIndexing(_ service: IndexingService, error: Error?) {
        if let error = error {
            print("Indexing Error:", error.localizedDescription)
            indexingViewController?.update(with: nil, error: error)
        } else {
            print("Indexing Error with no reason specified.")
        }
    }

    func updatedProgress(_ service: IndexingService, completed: Double) {
        indexingViewController?.update(with: completed, error: nil)
    }
}
