//
//  CreateTokenViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-08.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Whisper
import UIKit

class CreateTokenViewController: UIViewController {
    
    @IBOutlet var tokenNameTextField: UITextField!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func createPersonalToken() {
        guard let tokenName = tokenNameTextField.text, !tokenName.isEmpty else {
            tokenNameTextField.shake()
            return
        }
        
        view.endEditing(true)
        
        createToken(assetCode: "\(tokenName)XLM")
    }
    
    @IBAction func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tokenNameTextField.becomeFirstResponder()
    }

    func setupView() {
        navigationItem.title = "Create Token"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        holdingView.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }
    
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "Creating Token..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }
    
    func displayCreateTokenSuccess() {
        self.view.endEditing(true)
        
        let message = Message(title: "Person token successfully created.", backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }
}

extension CreateTokenViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 8
    }
}

/*
 * Operations
 */
extension CreateTokenViewController {
    func createToken(assetCode: String) {
        showHud()
        
        AccountOperation.createPersonalToken(assetCode: assetCode) { completed
            in
            self.hideHud()
            
            if completed {
                self.displayCreateTokenSuccess()
            } else {
                let alert = UIAlertController(title: "Activation Error", message: "Sorry your personal token could not be added at this time. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
