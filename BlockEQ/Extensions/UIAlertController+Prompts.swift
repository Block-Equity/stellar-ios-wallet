//
//  UIAlertController+Prompts.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-28.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

extension UIAlertController {
    static func simpleError(title: String, message: String, presentingViewController: UIViewController) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil)
        controller.addAction(action)

        presentingViewController.present(controller, animated: true, completion: nil)
    }
}
