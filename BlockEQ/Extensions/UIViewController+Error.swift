//
//  UIViewController+Error.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-03.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol FrameworkErrorPresentable {
    func displayFrameworkError(_ error: FrameworkError?, fallbackData: (title: String, message: String))
}

extension FrameworkErrorPresentable {
    func display(_ error: FrameworkError?,
                 viewController: UIViewController,
                 fallbackData: (title: String, message: String)) {
        var title = fallbackData.title
        var message = fallbackData.message

        if let error = error {
            title = error.displayData.titleKey.localized()
            message = error.displayData.messageKey.localized()
        }

        UIAlertController.simpleAlert(title: title, message: message, presentingViewController: viewController)
    }
}

extension FrameworkErrorPresentable where Self: UIViewController {
    func displayFrameworkError(_ error: FrameworkError?, fallbackData: (title: String, message: String)) {
        display(error, viewController: self, fallbackData: fallbackData)
    }
}
