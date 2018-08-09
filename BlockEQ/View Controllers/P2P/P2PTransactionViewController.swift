//
//  P2PTransactionViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-08.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class P2PTransactionViewController: UIViewController {
    
    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        navigationItem.title = "Add Transaction"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
