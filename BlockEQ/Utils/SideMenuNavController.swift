//
//  SideMenuNavController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import SideMenu
import UIKit

class SideMenuNavController: UISideMenuNavigationController {

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
