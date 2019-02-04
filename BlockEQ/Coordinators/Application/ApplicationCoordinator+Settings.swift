//
//  ApplicationCoordinator+Settings.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension ApplicationCoordinator: SettingsCoordinatorDelegate {
    func requestedAuthentication(_ coordinator: SettingsCoordinator,
                                 with options: AuthenticationCoordinator.AuthenticationOptions,
                                 authorized: EmptyCompletion?) {
        displayAuth {
            authorized?()
        }
    }
}
