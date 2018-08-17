//
//  AppDelegate.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let container = WrapperVC()
    let onboardingCoordinator = OnboardingCoordinator()
    var appCoordinator = ApplicationCoordinator()
    var authenticationCoordinator: AuthenticationCoordinator?
    var onboardingContainer: Bool = false
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = window ?? UIWindow(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
        window?.rootViewController = container
        window?.makeKeyAndVisible()

        onboardingCoordinator.delegate = self
        appCoordinator.delegate = self

        if !KeychainHelper.isExistingInstance() {
            onboardingContainer = true
            container.moveToViewController(onboardingCoordinator.navController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: nil)
        } else {
            onboardingContainer = false
            container.moveToViewController(appCoordinator.tabController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: {
                                            self.appCoordinator.tabController.moveTo(tab: .assets)
            })
            
            authenticate()
        }

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let presentedController = appCoordinator.tabController.presentedViewController {
            presentedController.dismiss(animated: false, completion: nil)
        }
        
        authenticate()
    }
    
    func authenticate(_ style: AuthenticationCoordinator.AuthenticationStyle? = nil) {
        guard SecurityOptionHelper.check(.pinOnLaunch) else {
            return
        }
        
        if let authCoordinator = self.authenticationCoordinator {
            authCoordinator.authenticate()
        } else {
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
}

extension AppDelegate: ApplicationCoordinatorDelegate {
    func switchToOnboarding() {
        onboardingContainer = true
        onboardingCoordinator.navController.popToRootViewController(animated: false)
        container.moveToViewController(onboardingCoordinator.navController,
                                       fromViewController: appCoordinator.tabController,
                                       animated: true,
                                       completion: {
                                        self.appCoordinator = ApplicationCoordinator()
                                        self.appCoordinator.delegate = self
        })
    }
}

extension AppDelegate: OnboardingCoordinatorDelegate {
    func onboardingCompleted() {
        onboardingContainer = false
        container.moveToViewController(appCoordinator.tabController,
                                       fromViewController: onboardingCoordinator.navController,
                                       animated: true,
                                       completion: {
                                        self.appCoordinator.tabController.moveTo(tab: .assets)
        })
    }
}

extension AppDelegate: AuthenticationCoordinatorDelegate {
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
