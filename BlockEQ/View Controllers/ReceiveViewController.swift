//
//  ReceiveViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
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

            let alert = UIAlertController(title: "Your address has been successfully copied.",
                                          message: nil,
                                          preferredStyle: UIAlertControllerStyle.alert)

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
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
            navigationItem.title = "Token Address"
            addressTitleLabel.text = "YOUR TOKEN ADDRESS"
        } else {
            navigationItem.title = "Receive"
            addressTitleLabel.text = "YOUR WALLET ADDRESS"
        }

        let image = UIImage(named: "close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
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
        let data = value.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")

        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(filter?.outputImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor.init(cgColor: Colors.white.cgColor), forKey: "inputColor1")
        colorFilter?.setValue(CIColor.init(cgColor: Colors.primaryDark.cgColor), forKey: "inputColor0")

        let qrcodeImage = colorFilter?.outputImage
        let scaleX = imageView.frame.size.width / (qrcodeImage?.extent.size.width)!
        let scaleY = imageView.frame.size.height / (qrcodeImage?.extent.size.height)!
        let transformedImage = qrcodeImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        activityIndicator.stopAnimating()

        imageView.image = UIImage(ciImage: transformedImage!)
    }
}
