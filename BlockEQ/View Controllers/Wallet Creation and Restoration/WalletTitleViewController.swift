//
//  WalletTitleViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class WalletTitleViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var underlineView: UIView!

    @IBAction func saveTitle() {
        dismissView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: String(describing: WalletTitleViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        navigationItem.title = "New Wallet"

        let image = UIImage(named: "close")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem

        textField.textColor = Colors.primaryDark
        textField.text = "My Wallet"
        view.backgroundColor = Colors.lightBackground

        underlineView.backgroundColor = Colors.primaryDark
        underlineView.alpha = Alphas.transparent
    }

    @objc func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }
}
