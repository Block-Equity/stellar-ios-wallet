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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let width = navigationBar.frame.size.width
        let height = UIApplication.shared.statusBarFrame.size.height + navigationBar.frame.size.height
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Colors.secondaryDark.cgColor, Colors.primaryDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        
        navigationBar.isTranslucent = false
        navigationBar.tintColor = Colors.white
        navigationBar.barTintColor = Colors.white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : Colors.white
        ]
        
        navigationBar.setBackgroundImage(self.image(fromLayer: gradientLayer), for: .default)
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}
