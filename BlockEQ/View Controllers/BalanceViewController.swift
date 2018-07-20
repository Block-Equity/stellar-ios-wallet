//
//  BalanceViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-12.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class BalanceViewController: UIViewController {
    
    @IBOutlet var availableBalanceView: UIView!
    @IBOutlet var totalBalanceView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        navigationItem.title = "XLM Balance"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        availableBalanceView.backgroundColor = Colors.primaryDark
        totalBalanceView.backgroundColor = Colors.primaryDark
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
