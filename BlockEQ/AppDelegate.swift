//
//  AppDelegate.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let blockEQWallet = BlockEQWallet()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = window ?? UIWindow(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))

        window?.rootViewController = blockEQWallet.container

        blockEQWallet.start()

        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        blockEQWallet.willEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        blockEQWallet.becameActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        blockEQWallet.enterBackground()
    }
}
