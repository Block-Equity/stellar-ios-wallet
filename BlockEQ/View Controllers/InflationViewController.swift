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
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var destinationAddressTextField: UITextField!
    
    let lumenautInflationDestination = "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"
    
    @IBAction func addInflationDestination() {
        guard let inflationDestination = destinationAddressTextField.text, !inflationDestination.isEmpty, inflationDestination.count > 20, inflationDestination != KeychainHelper.getAccountId() else {
            destinationAddressTextField.shake()
            return
        }
        
        showHud()
        
        AccountOperation.setInflationDestination(accountId: inflationDestination) { (completed) in
            self.hideHud()
            
            if completed {
                self.view.endEditing(true)
                
                self.dismissView()
            } else {
                let alert = UIAlertController(title: "Inflation Destination Error", message: "Sorry we were unable to set your inflation destination. Please check that your destination address is correct and try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self
        
        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
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
        navigationItem.title = "Set Inflation"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        titleLabel.textColor = Colors.darkGrayTransparent
        subtitleLabel.textColor = Colors.darkGray
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        destinationAddressTextField.text = lumenautInflationDestination
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
    
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Setting Inflation Destination..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
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
