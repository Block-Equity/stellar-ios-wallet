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

    @IBOutlet var buttonHolderView: UIView!
    @IBOutlet var pinViewHolder: UIView!
    @IBOutlet var pinView1: PinView!
    @IBOutlet var pinView2: PinView!
    @IBOutlet var pinView3: PinView!
    @IBOutlet var pinView4: PinView!
    @IBOutlet weak var keyboardView: KeyboardView!

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

    func setupView() {
        keyboardView.delegate = self
        keyboardView.update(with: KeyboardViewModel(options: KeyboardOptions.all,
                                                    buttons: [
                                                        ("1", ""),
                                                        ("2", "ABC"),
                                                        ("3", "DEF"),
                                                        ("4", "GHI"),
                                                        ("5", "JKL"),
                                                        ("6", "MNO"),
                                                        ("7", "PQRS"),
                                                        ("8", "TUV"),
                                                        ("9", "WXYZ"),
                                                        ("", ""),
                                                        ("0", ""),
                                                        ("R", "")],
                                                    bottomLeftImage: nil,
                                                    bottomRightImage: UIImage(named: "backspace"),
                                                    labelColor: .white,
                                                    buttonColor: .white,
                                                    backgroundColor: .clear))

        if isConfirming {
            title = "Confirm Pin"
            navigationItem.title = "Confirm Pin"
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            title = "Create Pin"
            navigationItem.title = "Create Pin"
            navigationItem.setHidesBackButton(true, animated: false)
        }
       
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if isCloseDisplayed {
            let image = UIImage(named:"close")
            let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }

        pinViewHolder.backgroundColor = Colors.primaryDark
        view.backgroundColor = Colors.primaryDark
        
        pinViews = [pinView1, pinView2, pinView3, pinView4]
        
        for pinView in pinViews {
            pinView.setEmpty()
        }
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectNext() {
        delegate?.pinEntryCompleted(self, pin: pin, save: shouldSavePin)

        if isCloseDisplayed {
            dismissView()
        }
    }
    
    func displayPinMismatchError() {
        for pinView in pinViews {
            pinView.setEmpty()
        }

        pin = ""
        
        let alert = UIAlertController(title: "Pin error",
                                      message: "Sorry your pin did not match. Please try again.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

extension PinViewController: KeyboardViewDelegate {
    func selected(key: KeyboardButton, action: UIEvent) {

        switch key {
        case .number(let num):
            guard pin.count < 4 else { return }
            pin += String(num)
        case .right:
            guard pin.count > 0 else { return }
            let index = pin.index(pin.startIndex, offsetBy: pin.count-1)
            pin = String(pin[..<index])
        default: print("???")
        }

        for (index, pinView) in pinViews.enumerated() {
            index < pin.count ? pinView.setFilled() : pinView.setEmpty()
        }

        if pin.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.delegate?.pinEntryCompleted(self, pin: self.pin, save: self.shouldSavePin)
                self.pin = ""
            }
        }
    }
}
