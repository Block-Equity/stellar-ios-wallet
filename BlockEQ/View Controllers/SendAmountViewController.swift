//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class SendAmountViewController: UIViewController {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var keyboardHolderView: UIView!
    @IBOutlet var keyboardPad1: UIButton!
    @IBOutlet var keyboardPad2: UIButton!
    @IBOutlet var keyboardPad3: UIButton!
    @IBOutlet var keyboardPad4: UIButton!
    @IBOutlet var keyboardPad5: UIButton!
    @IBOutlet var keyboardPad6: UIButton!
    @IBOutlet var keyboardPad7: UIButton!
    @IBOutlet var keyboardPad8: UIButton!
    @IBOutlet var keyboardPad9: UIButton!
    @IBOutlet var keyboardPadDot: UIButton!
    @IBOutlet var keyboardPad0: UIButton!
    @IBOutlet var keyboardPadBackspace: UIButton!
    @IBOutlet var sendAddressLabel: UILabel!
    
    var keyboardPads: [UIButton]!
    
    var amountString: String = ""
    
    @IBAction func keyboardTapped(sender: UIButton) {
        let keyboardPad = keyboardPads[sender.tag]
        if keyboardPad == keyboardPadBackspace {
            if amountString.count > 1 {
                amountString.remove(at: amountString.index(before: amountString.endIndex))
            } else {
                amountString = ""
            }
        } else if keyboardPad == keyboardPadDot {
            if amountString.count == 0 {
                amountString += "0."
            } else if amountString.range(of:".") == nil {
                amountString += "."
            }
        } else {
            if amountString.count == 0 && sender.tag == 0 {
                amountString = ""
            } else {
                amountString += String(sender.tag)
            }
        }
        
        amountLabel.text = amountString.count > 0 ? amountString : "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: SendAmountViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationItem.title = "My New Wallet"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    
        sendAddressLabel.textColor = Colors.darkGray
        amountLabel.textColor = Colors.primaryDark
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        sendAddressLabel.text = "TO: GDRXE2BQUC3AZNPVFSCEZ76NJ3WWL25FYFK6RGZGIEKWE4SOOHSUJUJ6"

        keyboardPads = [keyboardPad0, keyboardPad1, keyboardPad2, keyboardPad3, keyboardPad4, keyboardPad5, keyboardPad6, keyboardPad7, keyboardPad8, keyboardPad9, keyboardPadDot, keyboardPadBackspace]
        
        for (index, keyboardPad) in keyboardPads.enumerated() {
            keyboardPad.tintColor = Colors.primaryDark
            keyboardPad.setTitleColor(Colors.primaryDark, for: .normal)
            keyboardPad.backgroundColor = Colors.lightBackground
            keyboardPad.tag = index
        }
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
}
