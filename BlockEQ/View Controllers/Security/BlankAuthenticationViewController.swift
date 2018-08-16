//
//  AuthenticationViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-08-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol BlankAuthenticationViewControllerDelegate: AnyObject {
    func authenticate(_ viewController: BlankAuthenticationViewController)
}

/// The `AuthenticationViewController` class is a simple view controller to be used with Biometric authentication.
final class BlankAuthenticationViewController: UIViewController {
    @IBOutlet weak var authLogo: UIImageView!
    
    @IBOutlet weak var authButton: AppButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    weak var delegate: BlankAuthenticationViewControllerDelegate?
    
    func setupView() {
        self.view.backgroundColor = UIColor(red:0.136, green:0.168, blue:0.218, alpha:1.000)
        self.authLogo.image = UIImage(named: "logo")
        self.authLogo.contentMode = .top
        self.authButton.isHidden = true
        self.authButton.alpha = 0
        self.authButton.setTitle("AUTHENTICATE_TITLE".localized(), for: .normal)
        self.authButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func displayAuthButton() {
        self.authButton.isHidden = false
        
        let viewAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.5, animations: {
            self.authButton.alpha = 1
        })
        
        viewAnimator.startAnimation()
    }
    
    @IBAction func authenticatePressed(_ sender: Any) {
        delegate?.authenticate(self)
    }
}

extension BlankAuthenticationViewController: AuthenticatingViewController { }
