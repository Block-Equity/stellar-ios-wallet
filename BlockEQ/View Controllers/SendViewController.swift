//
//  SendViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {
    
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendTitleLabel: UILabel!
    @IBOutlet var sendAddressTextField: UITextField!
    
    var stellarAccount: StellarAccount = StellarAccount()
    var currentAssetIndex = 0
    
    @IBAction func addAmount() {
        
        guard let receiver = sendAddressTextField.text, !receiver.isEmpty, receiver.count > 20, receiver != KeychainHelper.getAccountId() else {
            sendAddressTextField.shake()
            return
        }
        
        view.endEditing(true)
        
        let sendAmountViewController = SendAmountViewController(stellarAccount: stellarAccount, currentAssetIndex: currentAssetIndex, reciever: receiver)
        navigationController?.pushViewController(sendAmountViewController, animated: true)
    }
    
    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self
        
        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(stellarAccount: StellarAccount, currentAssetIndex: Int) {
        super.init(nibName: String(describing: SendViewController.self), bundle: nil)
        
        self.stellarAccount = stellarAccount
        self.currentAssetIndex = currentAssetIndex
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setViewStateToNotEditing()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setupView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        sendTitleLabel.textColor = Colors.darkGrayTransparent
        sendAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        
        navigationItem.title = "\(stellarAccount.assets[currentAssetIndex].formattedBalance) \(stellarAccount.assets[currentAssetIndex].shortCode)"
    }
    
    func setViewStateToNotEditing() {
        view.endEditing(true)
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
}

extension SendViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        sendAddressTextField.text = value
    }
}
