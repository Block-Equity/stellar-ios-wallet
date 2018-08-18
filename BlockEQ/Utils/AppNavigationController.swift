//
//  AppNavigationController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        navigationBar.isTranslucent = true
        navigationBar.tintColor = Colors.primaryDark
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : Colors.black
        ]
    }
}
