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

    let address: String

    init(address: String) {
        self.address = address
        super.init(nibName: String(describing: ReceiveViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.address = ""
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayAccountAddress(address: address)
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ITEM_RECEIVE".localized()

        imageViewHolder.layer.shadowColor = Colors.shadowGray.cgColor
        imageViewHolder.layer.shadowOpacity = Float(Alphas.transparent)
        imageViewHolder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        imageViewHolder.layer.shadowRadius = 4.0

        addressTitleLabel.text = "YOUR_WALLET_ADDRESS".localized().uppercased()
        addressTitleLabel.textColor = Colors.darkGrayTransparent

        view.backgroundColor = Colors.lightBackground

        tableView.backgroundColor = Colors.lightBackground
        addressHolderView.backgroundColor = Colors.lightBackground
        qrHolderView.backgroundColor = Colors.primaryDark
        imageView.tintColor = Colors.primaryDark

        addressLabel.textColor = Colors.darkGray
        addressLabel.text = address
    }

    func displayCachedQRImage(address: String) -> Bool {
        guard let qrImage = try? CacheManager.shared.qrCodes.object(forKey: address) else {
            return false
        }

        activityIndicator.stopAnimating()
        imageView.image = qrImage.withRenderingMode(.alwaysTemplate)
        return true
    }

    func displayAccountAddress(address: String) {
        guard displayCachedQRImage(address: address) else {
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInitiated

            let operation = CacheAccountQROperation(accountId: address)
            operation.completionBlock = {
                _ = self.displayCachedQRImage(address: address)
            }

            operationQueue.addOperation(operation)
            return
        }
    }
}

// MARK: Actions
extension ReceiveViewController {
    @IBAction func copyAddress() {
        guard let addressText = addressLabel.text, !addressText.isEmpty else {
            return
        }

        UIPasteboard.general.string = addressLabel.text
        UIAlertController.simpleAlert(title: "ADDRESS_COPIED".localized(),
                                      message: nil,
                                      presentingViewController: self)
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
