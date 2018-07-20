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
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
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
    
    func setupView() {
        navigationItem.title = "Inflation".localized()

        tableView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGrayTransparent
        subtitleLabel.textColor = Colors.darkGray
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        
        destinationAddressTextField.text = lumenautInflationDestination
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Setting Inflation Destination..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }
    
    func dismissView() {
        view.endEditing(true)
        
        navigationController?.popViewController(animated: true)
    }
}

extension InflationViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        destinationAddressTextField.text = value
    }
}
