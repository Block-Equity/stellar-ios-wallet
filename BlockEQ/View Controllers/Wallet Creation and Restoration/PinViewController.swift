//
//  PinViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit
import Foundation

class PinViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var nextButton: AppButton!
    @IBOutlet var buttonHolderView: UIView!
    @IBOutlet var pinViewHolder: UIView!
    @IBOutlet var pinView1: PinView!
    @IBOutlet var pinView2: PinView!
    @IBOutlet var pinView3: PinView!
    @IBOutlet var pinView4: PinView!
    
    var pinViews: [PinView]!
    var previousPin: String!
    var mnemonic = ""
    
    @IBAction func textFieldDidChange() {
        guard let digits = textField.text, digits.count < 5 else {
            if let text = textField.text {
                let index4 = text.index(text.startIndex, offsetBy: 4)
                
                textField.text = String(text[..<index4])
            }
            return
        }
        
        for (index, pinView) in pinViews.enumerated() {
            if (index < digits.count) {
                pinView.setFilled()
            } else {
                pinView.setEmpty()
            }
        }
        
        if digits.count == 4 {
            nextButton.setEnabled()
        } else {
            nextButton.setDisabled()
        }
    }
    
    @IBAction func selectNext() {
        guard let pin = textField.text else {
            return
        }
        
        if let pinToConfirm = previousPin {
            if pin == pinToConfirm {
                savePin(pin: pin)
            } else {
                displayPinMismatchError()
            }
        } else {
            confirmPin(pin: pin)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(pin: String?, mnemonic: String) {
        super.init(nibName: String(describing: PinViewController.self), bundle: nil)
        
        self.previousPin = pin
        self.mnemonic = mnemonic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }

    func setupView() {
        if let _ = previousPin {
            navigationItem.title = "Confirm Pin"
            navigationItem.setHidesBackButton(false, animated: false)
            
            nextButton.setTitle("Confirm", for: .normal)
        } else {
            navigationItem.title = "Create Pin"
            navigationItem.setHidesBackButton(true, animated: false)
            
            nextButton.setTitle("Next", for: .normal)
        }
       
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        nextButton.backgroundColor = Colors.tertiaryDark
        pinViewHolder.backgroundColor = Colors.primaryDark
        view.backgroundColor = Colors.primaryDark
        
        nextButton.setDisabled()
        
        textField.inputAccessoryView = buttonHolderView
        
        pinViews = [pinView1, pinView2, pinView3, pinView4]
        
        for pinView in pinViews {
            pinView.setEmpty()
        }
    }
    
    func displayPinMismatchError() {
        let alert = UIAlertController(title: "Pin error", message: "Sorry your pin did not match. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmPin(pin: String) {
        let pinViewController = PinViewController(pin: pin, mnemonic: mnemonic)
        
        navigationController?.pushViewController(pinViewController, animated: true)
    }
    
    func savePin(pin: String) {
        KeychainHelper.save(pin: pin)
        
        let appNavController = navigationController as! AppNavigationController
        
        appNavController.accountCreationDelegate?.createAccount(mnemonic: mnemonic)
        
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
}
