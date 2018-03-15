//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class SendAmountViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var indicatorTitle: UILabel!
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
    
    let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    
    var keyboardPads: [UIButton]!
    var receiver: String = ""
    var sendingAmount: String = ""
    var stellarAccount: StellarAccount = StellarAccount()
    
    @IBAction func sendPayment() {
        guard let amount = amountLabel.text, !amount.isEmpty, amount != "0" else {
            return
        }
        
        signAndPostPaymentTransaction(to: receiver, amount: Decimal(string: amount)!)
    }
    
    @IBAction func keyboardTapped(sender: UIButton) {
        let keyboardPad = keyboardPads[sender.tag]
        if keyboardPad == keyboardPadBackspace {
            if sendingAmount.count > 1 {
                sendingAmount.remove(at: sendingAmount.index(before: sendingAmount.endIndex))
            } else {
                sendingAmount = ""
            }
        } else if keyboardPad == keyboardPadDot {
            if sendingAmount.count == 0 {
                sendingAmount += "0."
            } else if sendingAmount.range(of:".") == nil {
                sendingAmount += "."
            }
        } else {
            if sendingAmount.count == 0 && sender.tag == 0 {
                sendingAmount = ""
            } else {
                sendingAmount += String(sender.tag)
            }
        }
        
        amountLabel.text = sendingAmount.count > 0 ? sendingAmount : "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(stellarAccount: StellarAccount, reciever: String) {
        super.init(nibName: String(describing: SendAmountViewController.self), bundle: nil)
        
        self.receiver = reciever
        self.stellarAccount = stellarAccount
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationItem.title = "My Wallet"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        indicatorView.isHidden = true
    
        activityIndicator.tintColor = Colors.darkGray
        indicatorTitle.textColor = Colors.darkGray
        sendAddressLabel.textColor = Colors.darkGray
        amountLabel.textColor = Colors.primaryDark
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        sendAddressLabel.text = "To: \(receiver)"

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
    
    func displayTransactionError() {
        indicatorView.isHidden = false
        
        let alert = UIAlertController(title: "Transaction error", message: "There was an error processing this transaction. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

/**
 * Sending payment.
 */
extension SendAmountViewController {
    func signAndPostPaymentTransaction(to accountId: String, amount: Decimal) {
        indicatorView.isHidden = false
        
        if let privateKeyData =  KeychainHelper.getPrivateKey(), let publicKeyData =  KeychainHelper.getPublicKey()  {
            
            let publicBytes: [UInt8] = [UInt8](publicKeyData)
            let privateBytes: [UInt8] = [UInt8](privateKeyData)
            
            let sourceKeyPair = try! KeyPair(publicKey: PublicKey(publicBytes), privateKey: PrivateKey(privateBytes))
            let destinationKeyPair = try! KeyPair(publicKey: PublicKey.init(accountId: accountId), privateKey: nil)
            
            sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    do {
                        let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                                destination: destinationKeyPair,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: amount)
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation],
                                                          memo: Memo.none,
                                                          timeBounds:nil)
                        try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
                        
                        try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                            switch response {
                            case .success(_):
                                print("Transaction successful.")
                                DispatchQueue.main.async {
                                    self.dismissView()
                                }
                            case .failure(_):
                                self.displayTransactionError()
                            }
                        }
                    }
                    catch {
                        self.displayTransactionError()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayTransactionError()
                }
            }
        }
    }
}
