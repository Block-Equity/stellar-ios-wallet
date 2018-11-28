//
//  UIAlertController+Prompts.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

extension UIAlertController {
    static func simpleAlert(title: String, message: String?, presentingViewController: UIViewController) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil)
        controller.addAction(action)

        presentingViewController.present(controller, animated: true, completion: nil)
    }

    static func prompt(title: String,
                       message: String?,
                       handler: @escaping (UIAlertController) -> Void,
                       presentingViewController: UIViewController,
                       placeholder: String? = nil,
                       okText: String? = "GENERIC_OK_TEXT".localized(),
                       cancelText: String? = "CANCEL_ACTION".localized(),
                       secureText: Bool = false
                       ) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: okText, style: .default, handler: { _ in
            handler(controller)
        })

        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.addTextField { field in
            field.placeholder = placeholder
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.isSecureTextEntry = secureText
        }

        presentingViewController.present(controller, animated: true, completion: nil)
    }
}
