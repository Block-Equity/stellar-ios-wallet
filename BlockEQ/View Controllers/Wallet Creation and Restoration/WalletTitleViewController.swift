//
//  WalletTitleViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class WalletTitleViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var underlineView: UIView!

    init() {
        super.init(nibName: String(describing: WalletTitleViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        navigationItem.title = "NEW_WALLET".localized()

        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem

        textField.textColor = Colors.primaryDark
        textField.text = "MY_WALLET".localized()
        view.backgroundColor = Colors.lightBackground

        underlineView.backgroundColor = Colors.primaryDark
        underlineView.alpha = Alphas.transparent
    }

    @IBAction func saveTitle() {
        dismissView()
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}
