//
//  ReceiveViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class ReceiveViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var addressTitleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var imageViewHolder: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var qrHolderView: UIView!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    var address: String = ""
    var isPersonalToken: Bool = false

    @IBAction func copyAddress() {
        if let addressText = addressLabel.text, !addressText.isEmpty {
            UIPasteboard.general.string = addressLabel.text

            let alert = UIAlertController(title: "ADDRESS_COPIED".localized(),
                                          message: nil,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    init(address: String, isPersonalToken: Bool) {
        super.init(nibName: String(describing: ReceiveViewController.self), bundle: nil)
        self.address = address
        self.isPersonalToken = isPersonalToken
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        displayGeneratedAddress(value: address)
    }

    func setupView() {
        if isPersonalToken {
            navigationItem.title = "TOKEN_ADDRESS".localized()
            addressTitleLabel.text = "YOUR_TOKEN_ADDRESS".localized().uppercased()
        } else {
            navigationItem.title = "ITEM_RECEIVE".localized()
            addressTitleLabel.text = "YOUR_WALLET_ADDRESS".localized().uppercased()
        }

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        imageViewHolder.layer.shadowColor = Colors.shadowGray.cgColor
        imageViewHolder.layer.shadowOpacity = Float(Alphas.transparent)
        imageViewHolder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        imageViewHolder.layer.shadowRadius = 4.0

        addressLabel.textColor = Colors.darkGray
        addressTitleLabel.textColor = Colors.darkGrayTransparent
        addressHolderView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        qrHolderView.backgroundColor = Colors.primaryDark

        addressLabel.text = address
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    func displayGeneratedAddress(value: String) {
        let map = QRMap(with: value, correctionLevel: .full)
        imageView.image = map.scaledTemplateImage(scale: 10)
        activityIndicator.stopAnimating()
    }
}
