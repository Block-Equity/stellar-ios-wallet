//
//  AppNavigationController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        navigationBar.isTranslucent = true
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = Colors.primaryDark

        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Colors.black
        ]
    }
}
