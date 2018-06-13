//
//  AppDelegate.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var pinViewController: PinViewController?
    let container = WrapperVC()
    let appCoordinator = ApplicationCoordinator()
    let onboardingCoordinator = OnboardingCoordinator()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = window ?? UIWindow(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
        window?.rootViewController = container
        window?.makeKeyAndVisible()

        onboardingCoordinator.delegate = self
        appCoordinator.delegate = self

        if !KeychainHelper.isExistingInstance() {
            container.moveToViewController(onboardingCoordinator.navController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: nil)
        } else {
            container.moveToViewController(appCoordinator.tabController,
                                           fromViewController: nil,
                                           animated: false,
                                           completion: {
                                            self.appCoordinator.tabController.moveTo(tab: .assets)
            })
        }

        displayPin()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let pinController = pinViewController {
            pinController.dismiss(animated: false, completion: nil)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        displayPin()
    }

    func displayPin() {
        guard PinOptionHelper.check(.pinOnLaunch) else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let pinVC = PinViewController(mode: .dark, pin: nil, confirming: true, isCloseDisplayed: false, shouldSavePin: false)
            pinVC.delegate = self

            self.pinViewController = pinVC

            self.container.present(pinVC, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: ApplicationCoordinatorDelegate {
    func switchToOnboarding() {
        onboardingCoordinator.navController.popToRootViewController(animated: false)
        container.moveToViewController(onboardingCoordinator.navController,
                                       fromViewController: appCoordinator.tabController,
                                       animated: true,
                                       completion: nil)
    }
}

extension AppDelegate: OnboardingCoordinatorDelegate {
    func onboardingCompleted() {
        container.moveToViewController(appCoordinator.tabController,
                                       fromViewController: onboardingCoordinator.navController,
                                       animated: true,
                                       completion: {
                                        self.appCoordinator.tabController.moveTo(tab: .assets)
        })
    }
}

extension AppDelegate: PinViewControllerDelegate {
    func pinEntryCancelled(_ vc: PinViewController) {
        vc.dismiss(animated: true, completion: nil)
    }

    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool) {
        if KeychainHelper.checkPin(inPin: pin) {
            vc.dismiss(animated: true, completion: nil)
        } else {
            vc.pinMismatchError()
        }
    }
}
