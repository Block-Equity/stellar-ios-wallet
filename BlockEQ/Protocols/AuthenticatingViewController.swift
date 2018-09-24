//
//  AuthenticatingViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-08-15.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol AuthenticatingViewController {
    func dismissAuthentication(animated: Bool, completion: (() -> Void)?)
}

extension AuthenticatingViewController where Self: UIViewController {
    func fadeAnimator(duration: Double, completion: (() -> Void)?) {
        let alphaAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.5) {
            self.view.alpha = 0
        }

        alphaAnimator.addCompletion { _ in
            completion?()
        }

        alphaAnimator.startAnimation()
    }

    func dismissAuthentication(animated: Bool, completion: (() -> Void)?) {
        if let parent = self.parent {
            if let parentNavController = parent as? UINavigationController {
                parentNavController.popViewController(animated: animated)
                completion?()
            } else {
                self.fadeAnimator(duration: animated ? 0.75 : 0) {
                    self.removeFromParentViewController()
                    self.view.removeFromSuperview()
                    completion?()
                }
            }
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
}
