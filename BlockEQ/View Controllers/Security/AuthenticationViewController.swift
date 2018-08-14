//
//  AuthenticationViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-08-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

/// The `AuthenticationViewController` class is a simple view controller to be used with Biometric authentication.
final class AuthenticationViewController: UIViewController {
    @IBOutlet weak var authLogo: UIImageView!
    
    func setupView() {
        self.view.backgroundColor = Colors.primaryDark
        self.authLogo.image = UIImage(named: "logo")
        self.authLogo.contentMode = .top
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
}
