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
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var holdingView: UIView!
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
        
        addKeyboardNotifications()
        
        setViewStateToNotEditing()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeKeyboardNotifications()
    }

    func setupView() {
        navigationItem.title = "My Wallet"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        balanceLabel.textColor = Colors.black
        sendTitleLabel.textColor = Colors.darkGrayTransparent
        sendAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        balanceLabel.text = "\(stellarAccount.assets[currentAssetIndex].formattedBalance) \(stellarAccount.assets[currentAssetIndex].shortCode)"
    }
    
    func setViewStateToNotEditing() {
        view.endEditing(true)
        
        bottomLayoutConstraint.constant = 0.0
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard let userInfo = (notification as Notification).userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let newHeight: CGFloat
        if #available(iOS 11.0, *) {
            newHeight = value.cgRectValue.height - view.safeAreaInsets.bottom
        } else {
            newHeight = value.cgRectValue.height
        }
        
        bottomLayoutConstraint.constant = newHeight
        
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomLayoutConstraint.constant = 0.0
        
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
