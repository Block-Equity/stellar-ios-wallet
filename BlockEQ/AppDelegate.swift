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
        let bundleURL = Bundle.main.url(forResource: "Root", withExtension: "plist", subdirectory: "Settings.bundle")
        readSettings(from: bundleURL)

        blockEQWallet.becameActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        blockEQWallet.enterBackground()
    }
}

extension AppDelegate {
    func readSettings(from bundle: URL?) {
        let userDefaults = UserDefaults.standard
        if let url = bundle, let settings = NSDictionary(contentsOf: url),
            let preferences = settings["PreferenceSpecifiers"] as? [NSDictionary] {

            var defaultsToRegister = [String: AnyObject]()
            for preference in preferences.enumerated() {
                let item = preference.element
                guard let key = item["Key"] as? String, let value = item["DefaultValue"] else {
                    continue
                }

                defaultsToRegister[key] = value as AnyObject
            }

            userDefaults.register(defaults: defaultsToRegister)
        }
    }
}
