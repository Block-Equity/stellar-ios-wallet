//
//  AppNavigationController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol AccountCreationDelegate: class {
    func createAccount(mnemonic: String)
}

class AppNavigationController: UINavigationController {
    weak var accountCreationDelegate: AccountCreationDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let width = navigationBar.frame.size.width
        let height = UIApplication.shared.statusBarFrame.size.height + navigationBar.frame.size.height
        let gradientLayer = CAGradientLayer.simpleGradient(width: width,
                                                           height: height,
                                                           colors: [Colors.secondaryDark.cgColor,
                                                                    Colors.primaryDark.cgColor])
        
        navigationBar.isTranslucent = false
        navigationBar.tintColor = Colors.white
        navigationBar.barTintColor = Colors.white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : Colors.white
        ]
        
        navigationBar.setBackgroundImage(gradientLayer.image(), for: .default)
    }
}
