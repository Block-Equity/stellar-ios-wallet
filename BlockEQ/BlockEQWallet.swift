//
//  BlockEQWallet.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-16.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub
import os.log

final class BlockEQWallet {
    let container = WrapperVC()
    let onboardingCoordinator = OnboardingCoordinator()
    var appCoordinator = ApplicationCoordinator()

    var authenticationCoordinator: AuthenticationCoordinator?
    var onboardingContainer: Bool = false
    var core: CoreService!

    var network: StellarConfig.HorizonAPI {
        let network = UserDefaults.standard.string(forKey: "setting.network")
        return StellarConfig.HorizonAPI.from(string: network)
    }

    init() {
        core = CoreService(with: network)

        onboardingCoordinator.delegate = self
        appCoordinator.delegate = self

        onboardingCoordinator.core = self.core
    }

    func willEnterForeground() {
        if let presentedController = appCoordinator.tabController.presentedViewController {
            presentedController.dismiss(animated: false, completion: nil)
        }

        authenticate()

        appCoordinator.willEnterForeground()
    }

    func becameActive() {
        if !onboardingContainer {
            appCoordinator.didBecomeActive()
        }
    }

    func enterBackground() {
        if !onboardingContainer {
            appCoordinator.didEnterBackground()
        }
    }

    func reset() {
        core = CoreService(with: network)
    }

    func start() {
        if !KeychainHelper.hasExistingInstance {
            onboardingContainer = true
            container.moveToViewController(onboardingCoordinator.navController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: nil)
        } else {
            appCoordinator.core = self.core

            onboardingContainer = false
            container.moveToViewController(appCoordinator.tabController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: {
                                            self.appCoordinator.tabController.moveTo(tab: .assets)
            })

            authenticate()
        }
    }

    func authenticate(_ style: AuthenticationCoordinator.AuthenticationStyle? = nil) {
        guard SecurityOptionHelper.check(.pinOnLaunch) else {
            return
        }

        let container = onboardingContainer ? onboardingCoordinator.navController : self.container
        let opts = AuthenticationCoordinator.AuthenticationOptions(cancellable: false,
                                                                   presentVC: false,
                                                                   forcedStyle: style,
                                                                   limitPinEntries: true)
        let authCoordinator = AuthenticationCoordinator(container: container, options: opts)
        authCoordinator.delegate = self
        authenticationCoordinator = authCoordinator

        authCoordinator.authenticate()
    }
}

extension BlockEQWallet: ApplicationCoordinatorDelegate {
    func switchToOnboarding() {
        reset()

        onboardingContainer = true
        onboardingCoordinator.navController.popToRootViewController(animated: false)
        container.moveToViewController(onboardingCoordinator.navController,
                                       fromViewController: appCoordinator.tabController,
                                       animated: true,
                                       completion: nil)
    }
}

extension BlockEQWallet: OnboardingCoordinatorDelegate {
    func onboardingCompleted(service: CoreService) {
        onboardingContainer = false
        appCoordinator.core = service
        container.moveToViewController(appCoordinator.tabController,
                                       fromViewController: onboardingCoordinator.navController,
                                       animated: true,
                                       completion: {
                                        self.appCoordinator.tabController.moveTo(tab: .assets)
        })
    }
}

extension BlockEQWallet: AuthenticationCoordinatorDelegate {
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext) {
    }

    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext) {
        switchToOnboarding()

        // Setting the authentication coordinator to nil forces it to remove authentication views from the hierarchy
        authenticationCoordinator = nil
    }

    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?) {
        authenticationCoordinator = nil
    }
}
