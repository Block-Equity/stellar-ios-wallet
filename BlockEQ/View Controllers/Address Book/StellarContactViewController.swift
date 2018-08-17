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
    @IBOutlet var nameTitleLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    
    var identifier: String = ""
    var name: String = ""
    var address: String = ""
    
    @IBAction func addAddress() {
        guard let name = nameTextField.text, !name.isEmpty else {
            nameTextField.shake()
            return
        }
        
        guard let address = addressTextField.text, !address.isEmpty, address.count > 20 else {
            addressTextField.shake()
            return
        }
        
        if identifier.isEmpty {
            createContact(name: name, address: address)
        } else {
            updateContact(name: name, address: address)
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
    
    init(identifier: String, name: String, address: String) {
        super.init(nibName: String(describing: StellarContactViewController.self), bundle: nil)
        self.identifier = identifier
        self.name = name
        self.address = address
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        if identifier.isEmpty {
            navigationItem.title = "Add Contact"
        } else {
            navigationItem.title = "Update Contact"
        }
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        addressTitleLabel.textColor = Colors.darkGrayTransparent
        addressTextField.textColor = Colors.darkGray
        nameTitleLabel.textColor = Colors.darkGrayTransparent
        nameTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
        tableView.backgroundColor = Colors.lightBackground
        
        addressTextField.text = address
        nameTextField.text = name
    }
    
    func createContact(name: String, address: String) {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let fetchError = error {
                print("Unable to get contacts", fetchError)
                return
            }
            
            if granted {
                let mutableContact = CNMutableContact()
                mutableContact.givenName = name
                mutableContact.emailAddresses.append(CNLabeledValue(label: "Stellar", value: "\(address).publicaddress@blockeq.com" as NSString))
                
                self.createContact(contact: mutableContact)
            }
        }
    }
    
    func updateContact(name: String, address: String) {
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
                    
                    var previousEmailFound: Bool = false
                    var previousEmailIndex: Int = 0
                    for (index, emailAddress) in mutableContact.emailAddresses.enumerated() {
                        if emailAddress.value.contains(".publicaddress@blockeq.com") {
                            previousEmailFound = true
                            previousEmailIndex = index
                            break
                        }
                    }
                    
                    if previousEmailFound {
                        mutableContact.emailAddresses[previousEmailIndex] = stellarEmail
                        mutableContact.emailAddresses.append(stellarEmail)
                    } else {
                        mutableContact.emailAddresses.append(stellarEmail)
                    }
                    
                    self.saveContact(contact: mutableContact)
                }
                catch {
                    print("Unable to fetch contacts.")
                }
            }
        }
    }
    
    func saveContact(contact: CNMutableContact) {
        let req = CNSaveRequest()
        req.update(contact)
        let store = CNContactStore()
        do {
            try store.execute(req)
            DispatchQueue.main.async {
                self.dismissView()
            }
        } catch {
            let _error = error as NSError
            print(_error)
        }
    }
    
    func createContact(contact: CNMutableContact) {
        let req = CNSaveRequest()
        req.add(contact, toContainerWithIdentifier: nil)
        let store = CNContactStore()
        do {
            try store.execute(req)
            DispatchQueue.main.async {
                self.dismissView()
            }
        } catch {
            let _error = error as NSError
            print(_error)
        }
    }
}

extension StellarContactViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        addressTextField.text = value
    }
}
