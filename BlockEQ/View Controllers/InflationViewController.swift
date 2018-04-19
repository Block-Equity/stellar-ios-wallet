//
//  InflationViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-19.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class InflationViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var destinationAddressTextField: UITextField!
    
    @IBAction func addInflationDestination() {
        
        guard let receiver = destinationAddressTextField.text, !receiver.isEmpty, receiver.count > 20, receiver != KeychainHelper.getAccountId() else {
            destinationAddressTextField.shake()
            return
        }
        
        view.endEditing(true)
        
        dismissView()
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
    
    init() {
        super.init(nibName: String(describing: InflationViewController.self), bundle: nil)
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
        navigationItem.title = "Inflation Destination"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let image = UIImage(named:"close")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem
    
        titleLabel.textColor = Colors.darkGrayTransparent
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
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

extension InflationViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        destinationAddressTextField.text = value
    }
}
