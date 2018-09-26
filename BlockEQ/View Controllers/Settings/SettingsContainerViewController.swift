//
//  SettingsContainerViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import UIKit

final class SettingsContainerViewController: UINavigationController {

    /// The setings view controller requires a dark navigation bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStyle()
    }

    func setupStyle() {
        navigationBar.prefersLargeTitles = true
    }
}
