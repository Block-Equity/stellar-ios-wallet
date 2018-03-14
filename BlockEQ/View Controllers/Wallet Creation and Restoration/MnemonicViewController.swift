//
//  MnemonicViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class MnemonicViewController: UIViewController {
    
    @IBOutlet var holderView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mnemonicHolderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var mnemonic = ""
    
    @IBAction func confirmPhrase() {
        let verificationViewController = VerificationViewController(type: .questions, mnemonic: mnemonic)
        
        navigationController?.pushViewController(verificationViewController, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: MnemonicViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        generateMnemonic()
    }
    
    func setupView() {
        navigationItem.title = "Secret Phrase"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let image = UIImage(named:"close")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        holderView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGray
        view.backgroundColor = Colors.primaryDark
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func generateMnemonic() {
        activityIndicator.stopAnimating()
        
        mnemonic = Wallet.generate24WordMnemonic()
        let words = mnemonic.components(separatedBy: " ")
        
        var originX: CGFloat = 0.0
        var originY: CGFloat = 0.0
        
        for (index, word) in words.enumerated() {
            let pillView = PillView(index: String(index + 1), title: word, origin: .zero)
            
            if index == 0 {
                mnemonicHolderView.addSubview(pillView)
                
                originX += pillView.frame.size.width
            } else {
                if originX + pillView.frame.size.width > mnemonicHolderView.frame.size.width - pillView.horizontalSpacing {
                    originY += pillView.verticalSpacing
                    originX = 0.0
                } else {
                    originX += pillView.horizontalSpacing
                }
                
                pillView.frame.origin = CGPoint(x: originX, y: originY)
                
                mnemonicHolderView.addSubview(pillView)
                
                originX += pillView.frame.size.width
            }
        }
    }
}
