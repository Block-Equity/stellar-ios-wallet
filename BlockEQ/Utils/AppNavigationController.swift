//
//  AppNavigationController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        /*let width = navigationBar.frame.size.width
        let height = UIApplication.shared.statusBarFrame.size.height + navigationBar.frame.size.height
        let gradientLayer = CAGradientLayer.simpleGradient(width: width,
                                                           height: height,
                                                           colors: [Colors.secondaryDark.cgColor,
                                                                    Colors.primaryDark.cgColor])*/
        
        navigationBar.isTranslucent = true
        navigationBar.tintColor = Colors.primaryDark
        //navigationBar.barTintColor = Colors.white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : Colors.black
        ]
        
        //navigationBar.setBackgroundImage(gradientLayer.image(), for: .default)
    }
}
