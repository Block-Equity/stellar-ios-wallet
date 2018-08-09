//
//  TrustedPartiesViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-01.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class TrustedPartiesViewController: UIViewController {
    
    @IBAction func addPeer() {
        
    }
    
    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        navigationItem.title = "Trusted Peers"
        
        let leftBarButtonItem = UIBarButtonItem(title: "Add Peer", style: .plain, target: self, action: #selector(self.addPeer))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
