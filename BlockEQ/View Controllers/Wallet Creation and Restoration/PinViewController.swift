//
//  PinViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit
import Foundation

protocol PinViewControllerDelegate: class {
    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool)
}

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
    var pin: String = ""
    var isConfirming: Bool = false
    var isCloseDisplayed: Bool = false
    var shouldSavePin: Bool = false
    
    weak var delegate: PinViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(pin: String?, confirming: Bool, isCloseDisplayed: Bool, shouldSavePin: Bool) {
        super.init(nibName: String(describing: PinViewController.self), bundle: nil)
        self.pin = pin ?? ""
        self.isConfirming = confirming
        self.isCloseDisplayed = isCloseDisplayed
        self.shouldSavePin = shouldSavePin
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
        textField.text = pin
    }

    func setupView() {

        if isConfirming {
            title = "Confirm Pin"
            navigationItem.title = "Confirm Pin"
            navigationItem.setHidesBackButton(false, animated: false)
            
            nextButton.setTitle("Confirm", for: .normal)
        } else {
            title = "Create Pin"
            navigationItem.title = "Create Pin"
            navigationItem.setHidesBackButton(true, animated: false)
            
            nextButton.setTitle("Next", for: .normal)
        }
       
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if isCloseDisplayed {
            let image = UIImage(named:"close")
            let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
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
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }

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

        delegate?.pinEntryCompleted(self, pin: pin, save: shouldSavePin)

        if isCloseDisplayed {
            dismissView()
        }
    }
    
    func displayPinMismatchError() {
        for pinView in pinViews {
            pinView.setEmpty()
        }
        
        textField.text = ""
        
        let alert = UIAlertController(title: "Pin error",
                                      message: "Sorry your pin did not match. Please try again.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
