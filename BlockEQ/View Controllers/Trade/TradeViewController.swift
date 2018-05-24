//
//  TradeViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class TradeViewController: UIViewController {
    
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var buttonHolderView: UIView!
    @IBOutlet var tradeFromButton: UIButton!
    @IBOutlet var tradeToButton: UIButton!
    @IBOutlet var tradeFromTextField: UITextField!
    @IBOutlet var tradeToTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        arrowImageView.tintColor = Colors.lightGray
        
        for subview in buttonHolderView.subviews {
            if let button = subview as? UIButton {
                button.backgroundColor = Colors.lightBackground
                button.setTitleColor(Colors.darkGray, for: .normal)
            }
        }
        
        tradeFromButton.backgroundColor = Colors.darkGrayTransparent
        tradeToButton.backgroundColor = Colors.darkGrayTransparent
        tradeFromTextField.textColor = Colors.darkGray
        tradeToTextField.textColor = Colors.darkGray
    }
}
