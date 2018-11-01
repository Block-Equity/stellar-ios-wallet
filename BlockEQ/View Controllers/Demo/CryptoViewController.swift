//
//  CryptoViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-10-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class CryptoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
    }
    
    func setupView() {
        navigationItem.title = "Deposit Litecoin"
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
