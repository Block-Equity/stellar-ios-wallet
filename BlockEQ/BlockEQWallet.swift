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

protocol DelegateResponder: AnyObject {
    func willEnterForeground()
    func didBecomeActive()
    func didEnterBackground()
}

final class BlockEQWallet {
    let authenticationCoordinator: AuthenticationCoordinator
    let container = WrapperVC()

    var isOnboarding: Bool {
        return onboardingCoordinator != nil
    }

    var isInWallet: Bool {
        return appCoordinator != nil
    }

    var onboardingCoordinator: OnboardingCoordinator?
    var appCoordinator: ApplicationCoordinator?
    var core: CoreService?

    public weak var currentResponder: DelegateResponder?

    var network: StellarConfig.HorizonAPI {
        let network = UserDefaults.standard.string(forKey: "setting.network")
        return StellarConfig.HorizonAPI.from(string: network)
    }

    init() {
        authenticationCoordinator = AuthenticationCoordinator()

        restartCore()
    }

    func createAppCoordinator() {
        guard let coreService = core else {
            // log error
            return
        }

        appCoordinator = ApplicationCoordinator(with: coreService)
        appCoordinator?.delegate = self
    }

    func createOnboarding() {
        guard let coreService = core else {
            // log error
            return
        }

        let coord = OnboardingCoordinator(with: coreService)
        onboardingCoordinator = coord
        onboardingCoordinator?.delegate = self
    }

    func cleanupOnboarding() {
        onboardingCoordinator = nil
    }

    func cleanupAppCoordinator() {
        appCoordinator = nil
    }

    func restartCore() {
        self.core = CoreService(with: network)
    }

    func start() {
        if KeychainHelper.hasExistingInstance {
            createAppCoordinator()

            guard let coordinator = appCoordinator else {
                // log error
                return
            }

            let tabController = coordinator.tabController
            container.moveToViewController(tabController, fromViewController: nil, animated: false, completion: {
                tabController.moveTo(tab: .assets)
                self.currentResponder = coordinator

            })

            if SecurityOptionHelper.check(.pinOnLaunch) {
                authenticationCoordinator.authenticate(with: AuthenticationCoordinator.defaultStartupOptions,
                                                       container: container)
            }
        } else {
            createOnboarding()

            guard let navController = onboardingCoordinator?.navController else {
                // log error
                return
            }

            container.moveToViewController(navController, fromViewController: nil, animated: false, completion: nil)
        }
    }
}

// MARK: - ApplicationCoordinatorDelegate
extension BlockEQWallet: ApplicationCoordinatorDelegate {
    func switchToOnboarding() {
        createOnboarding()

        guard let onboardingVC = onboardingCoordinator?.navController, let appTab = appCoordinator?.tabController else {
            // log error
            return
        }

        container.moveToViewController(onboardingVC, fromViewController: appTab, animated: true, completion: {
            self.cleanupAppCoordinator()
            self.currentResponder = nil
        })
    }

    func requestedAuthentication(_ coordinator: AuthenticationCoordinatorDelegate,
                                 container: UIViewController,
                                 options: AuthenticationCoordinator.AuthenticationOptions) {
        authenticationCoordinator.delegate = coordinator
        authenticationCoordinator.authenticate(with: options, container: container)
    }
}

// MARK: - OnboardingCoordinatorDelegate
extension BlockEQWallet: OnboardingCoordinatorDelegate {
    func onboardingCompleted(service: CoreService) {
        createAppCoordinator()

        guard let appCoordinator = self.appCoordinator, let onboardingCoordinator = self.onboardingCoordinator else {
            // log error
            return
        }

        let onboardingNav = onboardingCoordinator.navController
        let appTabVC = appCoordinator.tabController

        container.moveToViewController(appTabVC, fromViewController: onboardingNav, animated: true, completion: {
            appTabVC.moveTo(tab: .assets)
            self.currentResponder = appCoordinator

            self.cleanupOnboarding()
        })
    }
}
