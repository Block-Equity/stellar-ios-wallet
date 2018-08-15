//
//  StellarContactViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Contacts
import UIKit

class StellarContactViewController: UIViewController {
    
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addressTitleLabel: UILabel!
    @IBOutlet var addressTextField: UITextField!
    
    var identifier: String = ""
    var name: String = ""
    
    @IBAction func addAddress() {
        guard let address = addressTextField.text, !address.isEmpty, address.count > 20 else {
            addressTextField.shake()
            return
        }
        
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let fetchError = error {
                print("Unable to get contacts", fetchError)
                return
            }
            
            if granted {
                let predicate = CNContact.predicateForContacts(withIdentifiers: [self.identifier])
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                
                var contacts = [CNContact]()
                
                do {
                    contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
                    
                    if contacts.count == 0 {
                        print("No contacts were found matching the given name.")
                    } else {
                        print(contacts[0].givenName)
                    }
                    
                    let stellarEmail = CNLabeledValue(label:"Stellar", value:"\(address).publicaddress@blockeq.com" as NSString)
                    let mutableContact = contacts[0].mutableCopy() as! CNMutableContact
                    mutableContact.emailAddresses.append(stellarEmail)
                    let req = CNSaveRequest()
                    req.update(mutableContact)
                    let store = CNContactStore()
                    do {
                        try store.execute(req)
                        print("updateContact success")
                        DispatchQueue.main.async {
                            self.dismissView()
                        }
                    } catch {
                        let _error = error as NSError
                        print(_error)
                    }
                }
                catch {
                    print("Unable to fetch contacts.")
                }
            }
        }
        
    }
    
    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self
        
        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    init(identifier: String, name: String) {
        super.init(nibName: String(describing: StellarContactViewController.self), bundle: nil)
        self.identifier = identifier
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        navigationItem.title = name
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        addressTitleLabel.textColor = Colors.darkGrayTransparent
        addressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
    }
}

extension StellarContactViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        addressTextField.text = value
    }
}
