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
    
    var safeAreaPadding: CGFloat = 20.0
    var stellarAccount: StellarAccount = StellarAccount()
    
    @IBAction func addAmount() {
        guard let receiver = sendAddressTextField.text, !receiver.isEmpty else {
            return
        }
        
        let sendAmountViewController = SendAmountViewController(stellarAccount: stellarAccount, reciever: receiver)
        
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
    
    init(stellarAccount: StellarAccount) {
        super.init(nibName: String(describing: SendViewController.self), bundle: nil)
        
        self.stellarAccount = stellarAccount
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewDidDisappear(animated)
        
        removeKeyboardNotifications()
    }
    
    func setupView() {
        navigationItem.title = "My Wallet"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let image = UIImage(named:"close")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        balanceLabel.textColor = Colors.black
        sendTitleLabel.textColor = Colors.darkGrayTransparent
        sendAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        balanceLabel.text = "\(stellarAccount.balance) XLM"
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height - safeAreaPadding
            bottomLayoutConstraint.constant = keyboardSize.size.height + statusBarHeight
            
            if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomLayoutConstraint.constant = 0
        
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
